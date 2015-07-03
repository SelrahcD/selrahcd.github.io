# Blog post ideas
* Element adding form(form in form)
* Scope and communication (cycle pb ?)
* Timy serie...&

Timy :
    Project presentation
        Why : wrapping my head around DDD, CQRS, Event Sourcing, Restfull API, TShirts

    File structure :
        tout parent puis séparation vers tout enfants + web
        lecture du projet
        cqrs apply to one bc
        http://www.udidahan.com/wp-content/uploads/Clarified_CQRS.pdf
        https://leanpub.com/ddd-in-php


        find . -type d -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'

.
|____bin
|____src
| |____tshirtaday
| | |____catalog
| | | |____features
| | | | |____contexts
| | | |____src
| | | | |____Domain
| | | | | |____Admin
| | | | | |____Catalog
| | | | | |____TShirt
| | | | |____Infrastructure
| | | | | |____Repositories
| | | | | | |____InMemory
| | | |____tests
| | | | |____Domain
| | | | | |____Admin
| | | | | |____TShirt




    Writing a good user story for behat
        Difficulty to write story for Modeling by EXample
        http://everzet.com/post/99045129766/introducing-modelling-by-example
        http://dannorth.net/whats-in-a-story/

    Plusieurs niveaux behat : domain + api
        Modeling by example
        http://everzet.com/post/99045129766/introducing-modelling-by-example

    link between contexts : add to voting context when added to catalog
        use events

    API
    https://leanpub.com/build-apis-you-wont-hate


    Ressource

    http://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215
    https://vaughnvernon.co/?p=838


