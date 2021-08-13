---
layout: "post-no-feature"
title: "Generating dates and UUIDs easily in PhpStorm"
description: "Typing a date or generating an UUID is something you have to do a lot while writing tests. Here is a tip that allows to do so with only a few keystrokes in PhpStorm."
image: /images/2021-08-13-generating-dates-and-uuids-easily-in-phpstorm/demo.gif
category: articles
tags:
 - TIL
 - phpstorm
 - productivity
published: true
comments: true
---
Legacy codebases tend to lack tests. One way to introduce some safety net before messing around with the code is to add characterization tests.
In this kind of test, we feed some input to the system under test and look at the outputs, ensuring that they stay the same test run after test run. It's far easier to fix inputs once and for all.

When creating this type of test, we want to avoid moving or random values. Two of the most common are dates and UUIDs. While it's possible to generate UUIDs using external tools, there is room for improvement if you want to do everything directly in PhpStorm. Even if typing a date is not as painful, we can gain some time here too. 

PhpStorm, and probably all IntelliJ IDEs, allow creating Live templates. Live templates are templates that we can expand by typing an abbreviation and triggering the autocomplete. What's even more remarkable is that they can evaluate [expressions](https://www.jetbrains.com/help/phpstorm/template-variables.html#predefined_functions) when the abbreviation is expanded. This is what we'll use.

![Generating dates and UUIDs with a only few keystrokes.](/images/2021-08-13-generating-dates-and-uuids-easily-in-phpstorm/demo.gif)

## Generating the current date

For generating the current date, we can use the `date` expression provided by PhpStorm and bind it to a variable.

* In PhpStorm settings, go to `Editor > Live Templates`
* Expand the PHP section
* Click on the Add button, `+` on the right side, and select `Live template`
* In the abbreviation field, enter `$date$`. This is what we'll type to expand the template.
* In the template text field, enter `'$date$'$END$`.
* Click `Edit variables`
* In the line for the variable named `date`, add the expression `date("yyyy-MM-dd'T'HH:mm:ss.SSSz")`  and select `Skip if defined`
* Click `Define` below the ` ⚠️ No applicable contexts`
* Select `PHP > Expression`
* Save and close the settings with the `Ok` button.

## Generating a random UUID

Generating a UUID is slightly different because PhpStorm doesn't provide a function to create UUIDs directly, but it, fortunately, allows to run Groovy scripts.

* In PhpStorm settings, go to `Editor > Live Templates`
* Expand the PHP section
* Click on the Add button, `+` on the right side, and select `Live template`
* In the abbreviation field, enter `$uuid$`. This is what we'll type to expand the template.
* In the template text field, enter `'$uuid$'$END$`. 
* Click `Edit variables`
* In the line for the variable named `uuid`, add the expression `groovyScript("UUID.randomUUID().toString()")` and select `Skip if defined`
* Click `Define` below the ` ⚠️ No applicable contexts`
* Select `PHP > Expression`
* Save and close the settings with the `Ok` button.


And voila, we now can quickly insert the current date or a UUID in our code.

Thanks to PhpStorm allowing us to execute Groovy code, we can probably think of other ideas and save more time. For instance, it would probably make sense to generate a random date instead of the current one, as we could be in a particular case if the code has conditions based on the current date.