---
layout: "post-no-feature"
title: Smurfing a Twitter bot
description: "How I made a bot that retweet a French newspaper Twitter feed as a Smurf"
category: articles
tags: 
  - Node
  - Twitter
  - Javascript
  - Dev
  - Bot
published: true
---

## The idea

The idea came up a while ago when I was talking with colleagues : Would it be possible to make a bot able to retweet speaking as a Smurf ?

[Smurfs](http://en.wikipedia.org/wiki/The_Smurfs), or [Schtroumpfs](http://fr.wikipedia.org/wiki/Les_Schtroumpfs) in french are an imaginary population of small blue people living in a mushroom village. They were born in the imagination of
french illustrator Peyo. They speak a strange language, which is based on human language but where the replace some word with smurf.

<figure>
  <img src="http://resize2-gulli.ladmedia.fr/r/611,599,center-middle,ffffff/img/var/jeunesse/storage/images/gulli/chaine-tv/dessins-animes/les-schtroumpfs/personnages/schtroumpf-musicien/21227448-3-fre-FR/Schtroumpf-musicien_original_backup.jpg">
  <figcaption>A Smurf.</figcaption>
</figure>

I'm a follower of french newspaper [Le Monde](http://www.lemonde.fr/) on twitter([@lemondefr](https://twitter.com/lemondefr)) so I decided that
it would be a good test to try to smurf their tweets.

## Language analysis
The analysis of sentences is something complicated and might be harder in french than in some other languages. I didn't even a second imagine
I could get along with this project without a good parser. I searched the web for a few hours and finally discovered the work done by [Alpage](https://www.rocq.inria.fr/alpage-wiki/tiki-index.php?page=Accueil), a research group working at INRIA, the french computer science search institute.
They have created a set of tools that can analise a sentence and returns [lexems](http://en.wikipedia.org/wiki/Lexeme). You can [try it by yourself](http://alpage.inria.fr/frmgwiki/frmg_main/frmg_server) if you can speak a few words of french.

I tried to install the Alpage system but failed to do so and finally decided to call a demo page remotely, get the result and work with received data.  

<blockquote class="twitter-tweet" data-cards="hidden" lang="fr">
  <p>Droit de vote des schtroumpfs : Londres condamné à Strasbourg <a href="http://t.co/0mV5ahnxoK">http://t.co/0mV5ahnxoK</a></p>
  &mdash; Le Schtroumpf (@leschtroumpffr) <a href="https://twitter.com/leschtroumpffr/status/565125702379651072">10 Février 2015</a>
</blockquote>


## Dificulties
## Let it go
## Reception

<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
