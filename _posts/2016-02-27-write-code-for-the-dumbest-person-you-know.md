---
layout: post-no-feature
title: Write code for the dumbest person you know
description: "I'm dumb and I'm unable to understand your clever code."
category: articles
tags:
  - Dev
  - craftmanship
published: false
comments: true

---

## I'm dumb

You're lucky. You're lucky because you're clever and I'm not.

I noted that I was dumb when I was unable to understand how some data was injected into an object during its instantiation. 
I know what is a depency injection manager but that time it was not like the others. It took me one hour to figure out where that configuration parameter was coming from. I had to go through 8 code files and 3 configuration files and I had to make several full text searches in order to jump from file to file because following the code was misleading. This exercise was really hard to me because I'm barely able to remember my own phone number so I had to write down to paper the path of your clever way to do depency injection because I couldn't keep it in memory.

I have to say that I started to be pissed off - allright, this is not uncommon - because you code was telling me that I was stupid, and no one likes beeing told that she is stupid.

Someone then came by and told me it was the tool, a cool feature provided by the tool, that you were using. Again, I know what a dependency injection manager are, and how they work, but that one magical feature which allows you to make the same thing as usual but in a very clever way I don't know it. Probably because I never needed it. I guess appart from beeing dumb I also lack of culture about that tool features.

I was sure that I was dumb when I couldn't understand what you're abstraction was for. For me all the interesting thing your code was doing was concentrated in one class. That one class I found after going through several classes doing I don't really know what. That one class which was wrapping a class from a library.

I probably missed something but I have to say that [I started to be pissed off](https://twitter.com/Selrahcd/status/701794483726323712) again - I think there is some kind of pattern here. I tried to understand, because, after all, you're clever. Why would you do something that complicated when just using the class from the library, or your wrapper, would have done the job ? Maybe you were protecting us from the coupling to that library and making it uses simpler. I have to confess that I was surprised when I saw a massive chain of getters going all the way down to get the library object you were wrapping and pass it to the some other object.

This are some of the times I noticed I was dumb. Hard truth...

Thank you for beeing an eye opener.


## I used to be clever though

I used to be clever though. I used to write some pretty pieces of code which were doing all kind of cool stuff. I was theorically able to change the way the whole system was working by changing one parameter in a configuraion file. My code was able to cope with all future issues I had foreseen. I knew how to do some tricky things with all sort of tools.

But time goes on and aging probably made me dumb.

Aging or discoveries and failures.

Abstractions are good when you know what you're abstracting. Apparently you only know what you're abstracting based on the information you currently have. I couldn't predict future and the next needs. I tried though, I failed, and ended up [locked down by my clever abstraction](http://www.sandimetz.com/blog/2016/1/20/the-wrong-abstraction). And as we all do I started to cheat, broke my abstraction, used getters in order to get the internals and be able to manipulate them.

Not once but several times.

I made complexe stuff too. Yes, they were complexe, not complicated. Complexe because complexity was needed. Complexe not complicated, because complicated implies that it's hard to understand and follow and I was perfectly able to understand it. I wrote it after all. Then I moved on, worked on something else, and had to came by to it later probably because of something to fix. Apparently complexe code tend to be buggy. Moreover complexe code became complicated. I was now unable to understand easily what was going on with this code and all choices I made a few days before.

I have seen people reluctant to use some of my code. In my opinion it was not that hard to understand but you probably needed someone to guide you the first time you used the library because it was magic in some kind of way. We had a solution, we probably should have written documentation. Or simpler code : [something the junior of your team can grasp by herself](http://www.infoq.com/presentations/8-lines-code-refactoring).

I was pissed at myself on those occasions.

I guess some time you will be pissed at yourself too. I hope so. It means you code is used, and that's cool.

## Please stop

Please stop writing complicated stuff. It's harder to read, to understand, to test, and even to produce. Moreover it's unecessary, it doesn't protect you from futur requirements, it's hard and it costs time and money.

Please stop doing something everyone knows about in some other clever way. It's cool that you know everything about your tools, but what will be cooler is that you know when to use or use not a feature. [I don't want to be suprised while reading code](https://en.wikipedia.org/wiki/Principle_of_least_astonishment).

I want to read code as I read books, simple ones. I want to read book as I read Harry Potter, translated in french. As I said, I'm dumb, and I'm lazy...

Take a break, think two minutes about the piece of code you're about to craft : can you make it simple ? Can the dumbest person you know understand it ? Will she be surprised ? 

As you've been an eye opener to me I hope this words will be an eye opener to you too.

Go write some code. Simple one.