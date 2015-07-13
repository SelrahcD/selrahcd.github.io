---
layout: "post-no-feature"
title: Project module structure
description: "Reflections about the file organization of a project at the macro level"
category: articles
tags:
  - Dev
  - tshirtaday
published: true
comments: true
---

File organization is something crucial if you have to maintain a project for the long run but is often overlooked by developers. 

The way files are organized within a project is very important because it dictates how the team will work and at the end the overall quality of the software.

Using the traditional framework organization with a directory for each type of element (entities, services, controllers, ...) is one of the fastest way to produce tightly coupled pieces of software because all developers are working in the same area and have no boundaries to help them structure their code.

Furthermore this file organization doesn't convey any information about what the software does. As Robert C. Martin noted in his conference "Architecture the lost years" we should be able to identify the purpose of a project by looking at its structure at the macro level.

Providing a file structure which expresses the goal of the software helps a lot in the definition of boundaries inside the project. This boundaries can be used to determine the teams working on the project too. Having boundaries is also the starting point to the analyze of dependencies within the system.

In the TShirt a day project I have tried two files structure with the intent to give information about what the software does but I was unhappy with the first one that was not expressive enough in my opinion.

In this first version I focused to much in my attempt to segregate domain code from a potential framework. I made a directory to support all domain code containing the two current modules (votes and catalog). This two modules were also containing their behat's feature file.
The main issue with this approach is that you cannot tell what the system is about at first glance.

After refactoring the file structure the two modules are now placed at the top level, which is a huge gain on the expressiveness  of the system. Moreover the features' directory is also situated at the top level because they give a good description of what the entire system is about. I'm also trying to follow the example of Konstantin Korsakhov with is article Modeling by example and doing so might allow a feature to be accomplished by several modules altogether. For instance if I later introduce an API on top of the two modules I will need both the API module and the two others to interact to do the job.

This little refactoring helps showing the intent of the project. I'm currently happy with it and will see what will be the consequences of this decision during the lifetime of the project.