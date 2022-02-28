---
layout: "post-no-feature"
title: "Using Property Based Testing to test priorities"
description: "Once we've decomposed one unit in smaller part, Property Based Testing can help testing for priorities between each of the subparts."
category: articles
tags:
 - Testing
 - Property based testing
 - Unit tests
 - typescript
published: true
comments: true
---
I was recently working on a project with an Angular frontend where we displayed an action button. That button had to be disabled when some conditions were met. Examples of conditions are:
* not the proper access level 
* not enough "points in the wallet" to do the action
* action can't be performed on the selected item

There is no complex logic to knowing if a condition is triggered. Nevertheless, the service tasked with deciding if a condition was met was growing and was taking on more dependencies.

When the application was in a state where a condition was on, we displayed a tooltip to explain why the button was disabled.

Now, this is where the fun starts. Multiple conditions could be detected at a point in time: the action can't be performed on the selected item, and you don't even have enough points anyway, for instance.

We could argue that it would be better to display all messages at once to avoid our users playing the annoying error message game where they fix an error just to discover a new one again and again. Unfortunately for the user, it was decided to display error messages one by one for some reason.

It was unfortunate for us as well, as we now had to decide which message to display when several conditions were met. Obviously, not all states are born equals, and some are more important than others. The logic in the service was now also tasked with ordering the messages.

The code looked something like this:

```typescript
export class ButtonGuardLogic{
    

    vote() {
        
        switch (true) {
            case !this.authenticationService.isAuthenticated:
                return "You need to be authenticated";
            case this.anotherService.someState === 'not_a_good_state':
                return "You're not in a good state";
            case this.selectedItem.totalPointsNeeded > this.walletService.availablePoints:
                return "You don't have enough points in your wallet";
            case this.selectedItem.isSomething:
                return "You can't do this on an item that is in isSomething state";
            default:
                return '';
        }
    }
}

```

I changed it slightly to remove everything related to Observables as it's not the interesting part and to hide some of the business logic. You can still get the idea.

I was pairing with a colleague, planning to add a new message based on a condition that would require taking on a new dependency, and with almost no tests to help us. 

As you can imagine, if you want to cover all cases and ensure that the order of messages keeps being respected when multiple conditions are on, you need a lot of tests. If you're only interested in if the condition is met or not, and not on the data required by each condition to decide if it's on, we're talking 2^(number of conditions) test cases. For the code above, 16 test cases are needed. With the new condition we were about to add, it grows to 32.

We wanted to improve the code and agreed that it would be better to have each condition on its own, where we could test it separately and have a sort of glue class, selecting the right message to display, also tested aside.

As we weren't great Angular devs and were lost with the Observables and the way to test them, we didn't refactor the code and conformed to the current design. It bothered me, and I tried to see how I could improve it and better split testing conditions and message display.

I'll pretend we had only three conditions to simplify the examples for the following.

First, let's extract the conditions:

```typescript

export type ErrorMessage = string;
export type PositiveMessage = '';

export type GuardMessage = ErrorMessage | PositiveMessage;

export type ButtonGuard = {
    vote(): GuardMessage;
}

export class ButtonGuardA implements ButtonGuard {
    vote(): GuardMessage {
        return 'Error A';
    }
}

export class ButtonGuardB implements ButtonGuard {
    vote(): GuardMessage {
        return 'Error B';
    }
}


export class ButtonGuardC implements ButtonGuard {
    vote(): GuardMessage {
        return 'Error C';
    }
}
```

Here we defined a `ButtonGuard` type, containing a `vote` method that can reply with an `ErrorMessage` or a `PositiveMessage`. Each guard, or condition, implements this type, and can get the needed dependencies to decide if it wants to return a message or not. As all guards are separated, they can easily be tested.

Next, we add another type of `ButtonGuard`, which takes all the other guards, requests their votes, and returns the first `ErrorMessage` found. As with the switch case in the first design, the display order is still represented: here, it's the order of the guards we placed in the array.

```typescript
export class ButtonGuardLogic implements ButtonGuard{

    constructor(
        private readonly guardA: ButtonGuardA,
        private readonly guardB: ButtonGuardB,
        private readonly guardC: ButtonGuardC
    ) {}

    vote() {

        return [this.guardA, this.guardB, this.guardC]
            .map((guard) => guard.vote())
            .find(guardMessage => guardMessage !== '') || '';
    }
}
```

If no `ErrorMessage` was returned the `ButtonGuardLogic` returns with an empty string, the `PositiveMessage` type.

You may have noticed that this is the Composite design pattern in action.

Arguably, this code is already an improvement. We still need to test that the messages are displayed in the expected order, and it's time for Property Based Testing to come into play.

PBT frameworks work by trying many combinations of more or less random data on each test run for properties we've defined. The canonical example of a property is reversing twice a string should return that same string. A PBT framework will give us a lot of strings to try that property, including some we probably wouldn't think about trying (empty string, "null", string with non-Latin characters, a string containing numbers, ...).

Here the propriety we want to test is:

> "The displayed error message is the message with the highest priority returned from all guards."

Because we have extracted all conditions in simple guards, we can now easily say which of them are in an error state or not by providing a stubbed implementation. The PBT framework's job is to tell us which guards are in an error state. It's equivalent to saying that the PBT framework has to generate a list of boolean values, one for each guard, and we will map these booleans to set up the stubbed implementations.

As we know which guards are in an error state, we also know which error messages are produced and can get the one with the highest priority out of them. Then we can compare that value with the one returned by the implementation.

We need to have a way to control our individual guards. For this, I introduced a `FakeButtonGuard`:

```typescript
class FakeButtonGuard implements ButtonGuard {
    voteValue = '';

    vote(): GuardMessage {
        return this.voteValue;
    }
}
```

We will also need some constants that will come in handy later:

```typescript

const errorMessageByGuard = {
    A: 'Error message from guard A',
    B: 'Error message from guard B',
    C: 'Error message from guard C',
};

const positiveMessage = '';

let guards: {[guardName: string]: FakeButtonGuard} = {
    A: new FakeButtonGuard(),
    B: new FakeButtonGuard(),
    C: new FakeButtonGuard(),
};

const priorities : {[priority: number]: string} = {
    1: "Error message from guard A",
    2: "Error message from guard B",
    3: "Error message from guard C",
    4: ""
}

const guardCount = Object.keys(guards).length;
```

For each guard, we define its error message. Here it's a string, and it could be a constant defined in the guard classes as an improvement.
We also instantiate fake button guards for each guard and list error messages in the expected priority order. `guardCount` gives us a simple way to get the number of guards.

Before each test, we instantiate a `ButtonGuardLogic`:

```typescript

let buttonGuardLogic: ButtonGuardLogic;

beforeEach(() => {

    buttonGuardLogic = new ButtonGuardLogic(
        guards['A'],
        guards['B'],
        guards['C'],
    );

});
```

We are ready to add our test.

Using [Fast-Check](https://github.com/dubzzz/fast-check), a PBT framework for typescript, we generate an array of three, the number of guards, boolean values.

```typescript
it('displays error message by order of priority.', () => {

    fc.assert(fc.property(
        fc.array(fc.boolean(), {minLength: guardCount, maxLength: guardCount}),
        (activations: boolean[]) => {

           
        }
    ));

});
``` 

Next, we need to define a few functions.

The `buildGuardValues` function associates the activations of guards with their messages. It produces a dictionary where each guard name (A, B, or C) maps to either an empty string when the boolean value is true or the error message associated with the guard otherwise.

```typescript
const buildGuardValues = (activations: boolean[]) : GuardMessagesByGuardName => 
  Object.entries(errorMessageByGuard)
    .reduce((guardValues, [guardName, errorMessage], index) => {
        guardValues[guardName] = activations[index] ? positiveMessage : errorMessage;

        return guardValues;
    }, {});


```

`setupGuards` function sets each of the `FakeGuards` with their expected responses:

```typescript

const setupGuards = (guardValues: GuardMessagesByGuardName) => 
  Object.entries(guardValues)
    .forEach(([guardName, value]) => guards[guardName].voteValue = value);

```

With these two functions, we can map the generated array of boolean to the list of the guards' messages and initialize each guard with the value it's expected to return.

Next, we need to go through all the expected messages to find the one with the highest priority. To do this, I introduced the three following functions:

```typescript

const getPriority = (guardMessage: GuardMessage): number =>
  Object.entries(priorities)
      .find(([_priority, errorMessage]) => errorMessage === guardMessage)
      .map(([priority, _errorMessage]) => parseInt(priority))
      .shift();


const compareGuardMessagePriority = (guardMessage1: GuardMessage, guardMessage2: GuardMessage) : CompareResult => 
  getPriority(guardMessage1) < getPriority(guardMessage2) ? -1 : 1;


const getMessageWithHighestPriority = (guardMessages: GuardMessage[]) : GuardMessage => 
    guardMessages
    .sort(compareGuardMessagePriority)
    .shift();
```

`getPriority` gets the priority associated with an error message.

`compareGuardMessagePriority` compares two messages.

Finally, `getMessageWithHighestPriority` gives the message with the highest priority using the `compareGuardMessagePriority` function.

The message returned by `getMessageWithHighestPriority` is the one we expect given the provided array of booleans.

We can now tie all the pieces together to write the body of the test.

```typescript
it('displays error message by order of priority.', () => {

    fc.assert(fc.property(
        fc.array(fc.boolean(), {minLength: guardCount, maxLength: guardCount}), (activations: boolean[]) => {

            const guardValues = buildGuardValues(activations);
            setupGuards(guardValues);

            const buttonActivationWithHighestPriority = getMessageWithHighestPriority(Object.values(guardValues));

            const context = buildContext(activations);

            expect(buttonGuardLogic.vote())
                .to.equal(buttonActivationWithHighestPriority);
        }
    ));

});

```

We now have a test that will cover a lot of permutations of error activations.

When it is time to add a new condition, it will easily be created in its own `ButtonGuard`; that guard will easily be testable independently of the others. Then we will have to slightly modify the `ButtonGuardLogic` to add the new guard and its error message and let Fast-Check deal with testing the new permutations.





