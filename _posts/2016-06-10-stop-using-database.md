---
layout: post-no-feature
title: Stop using the database for everything
description: "I think we should start using database less."
category: articles
tags:
  - Dev
  - craftsmanship
published: false
comments: true

---

First thing first, database are useful in a lot of cases and we need them. We need them when we have to store information provided by users or information which change on a regular basis.

This is not the case of all data an application needs in order to run - currencies, countries, languages, application settings, to name a few. This types of information don't change that often and adding a database for them doesn't provide much value. Maybe a developer won't be needed in order to change or add a value but I'm inclined to think that more than often no tools is provided to business people and a developer will have to run a query on the database nevertheless. 

Adding a database in this cases is a cost with no value added. More code is needed, additional complexity is created, a database have to be maintained and the resulting system is probably slower - not in an important order of magnitude of course - than a system without a database.

These additional costs is not the main reason I dislike the use of database for such information.

In the long run special cases will probably be introduced in the application - do this for this country and that for that one for instance. Facing this special cases exist basically two solutions. Either you add the differentiating piece of data in the database, which might mean changing table schema and so on, in order to do something clean or you start cheating a use the reference of the concept with a special case - id, ISO standard reference - thus coupling code and database content altogether.

From what I've seen we, developers, will choose solution 2, maybe because we are lazy, in the middle of a rush or don't mesure the consequences of it.

Once the coupling is created it will eventually grow to the point where almost all data from the database is stored in the code or in a configuration file dedicated to mappings between code artifacts and database stored values. In the end a developper intervention will be necessary every time to update theses pieces of code. Back to square one.

If the data doesn't change much why not store it in the code after all ? Having only one golden source that is easily changeable - adding a property to a value object is way easier than changing a table schema - instead of two or more sources that will have to be maintained in cohesion.

When your dealing with some data that doesn't look like likely to change often try not to use a database. Start with a simple representation based on value objects if you are onto POO. If in the long run that information appears to change a lot then use a database. Start with the simpler solution that works.


If your a DBA, hate me, and want to tell me that I'm an awful person I'm on [Twitter](https://twitter.com/selrahcd). Feel free to comment below as well.