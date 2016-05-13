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


* Things I've learned : avoid magic, do not use a lib < 1 or update update update

Look alikes :
- DRY
- Database
- Model vs command
- Validation

Remove if :
outside
DI
null object


Do not create interface if you have only one possible way to combine your classes, or to force dev to make the implementation you want => Interfaces are meant to be at the interface of the logic block therefore we should not force how impl is done. If the impl you think of is that good dev adding new functionnality should not have to recreate the same X classes you did with your first impl. The more you force an impl the less flexibility you have. (ex : JWT and symfony security)


Test inversion :


Dont create a shitty solution in order to alleviate your shitty solution:
modale avec du contenu :
* partage de l'url ? => un bouton share
* clic sur un lien => navigation in modal ? => congrats you've created a new browser
* 

Find the root cause of the issue

Plusieurs niveaux de "sécurité" : hermod retry queues => only the last one is usefull


I'm too stupid to use your clever shit



Missed context dependency : message as an integration point for all our services


trim email address on log in form



Confusion between delivery mechanism and message :
Email vs content
webhook vs notification


Lazy :
+ ou - des deux solutions
 toLazy(store) in interface -> newLazy ou self
ou not in interface et instance of + method toLazy seulement dans memory imple


If statements
