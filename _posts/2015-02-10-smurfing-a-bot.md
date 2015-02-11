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

[Smurfs](http://en.wikipedia.org/wiki/The_Smurfs), or [Schtroumpfs](http://fr.wikipedia.org/wiki/Les_Schtroumpfs) in french, are an imaginary population of small blue people living in a mushroom village. They were born in the imagination of french illustrator Peyo. They speak a strange language, which is based on human language but where they replace some words with smurf.

<figure>
  <img src="http://resize2-gulli.ladmedia.fr/r/611,599,center-middle,ffffff/img/var/jeunesse/storage/images/gulli/chaine-tv/dessins-animes/les-schtroumpfs/personnages/schtroumpf-musicien/21227448-3-fre-FR/Schtroumpf-musicien_original_backup.jpg">
  <figcaption>A Smurf.</figcaption>
</figure>

I'm a follower of french newspaper [Le Monde](http://www.lemonde.fr/) on Twitter ([@lemondefr](https://twitter.com/lemondefr)) and I decided that
it would be a good test to try to smurf their tweets.

## Language analysis

The analysis of sentences is something complicated and might be harder in french than in some other language. I didn't even a second imagine
I could get along with this project without a good parser.

I searched the web for a few hours and finally discovered the work done by [Alpage](https://www.rocq.inria.fr/alpage-wiki/tiki-index.php?page=Accueil), a research group working at INRIA, the french computer science search institute.
They have created a set of tools that can analise a sentence and returns [lexems](http://en.wikipedia.org/wiki/Lexeme).

You can [try it by yourself](http://alpage.inria.fr/frmgwiki/frmg_main/frmg_server) if you can speak a few words of french.

I tried to install the Alpage system but failed to do so and finally decided to make a call to a demo page, get the result and work with the received data.

## Word transformation

Once the sentence is parsed into lexems the next step is to replace word by its smurf equivalent. Smurf language is not just about changing a word to smurf: you have to replace it with the smurf word in the same category.

<figure>
    <table>
        <tr>
            <th>Category</th>
            <th>Smurf form</th>
            <th>French word example</th>
        </tr>
        <tr>
            <td>Adverb</td>
            <td>schtroupfement</td>
            <td>admirablement</td>
        </tr>
        <tr>
            <td>Past verb, plural form</td>
            <td>schtroumpfaient</td>
            <td>venaient</td>
        </tr>
        <tr>
            <td>Noun, plural form</td>
            <td>schtroumpfs</td>
            <td>poneys</td>
        </tr>
    </table>
<figcaption>Examples of french-smurf translations</figcaption>
</figure>

I wrote a basic french-smurf [translation dictionnary](https://github.com/SelrahcD/leschtroumpffr/blob/master/language.js) to help me with the transformation.

Doing the transformation of one word is not enough. I also had to transform previous words in some cases where gender and number influence the preceding pronoun.

<figure>
    <table>
        <tr>
            <th>Smurf form</th>
            <th>French example</th>
        </tr>
        <tr>
            <td>Je schtroumpfe</td>
            <td>J'arrive</td>
        </tr>
        <tr>
            <td>De l'eau</td>
            <td>Du schtroumpf</td>
        </tr>
    </table>
<figcaption>Example of influence of gender and number on the translation</figcaption>
</figure>


I didn't try to be clever in the selection of the french word to transform : this is a total random thing.

## Integration with Twitter

The project is written in NodeJS and [Twit](https://github.com/ttezel/twit) does a good job when it comes to listen Twitter's stream API and to post a tweet so I didn't search for too long and decided to go with it.

The bot listen the stream API for each tweet from [@lemondefr](https://twitter.com/lemondefr) and delegate the transformation work to the [transformation tool](https://github.com/SelrahcD/leschtroumpffr/blob/master/schtroumpsify.js).

Once the text transformed the bot makes the call to tweet the smurfed version of the text.

## Release

As always I had a hard time convincing myself I should release an uncompleted project, with some known bugs and possible improvements, but I finally did it.
The bot is hosted on a DigitalOcean droplet.

Some bugs are persisting and I have to manually restart the bot once in a while. I also make some changes in the transformation algorithm when a tweet is not doing so well. 

## Results

The bot is living is own life [out there](https://twitter.com/leschtroumpffr). Go and follow it !

As the transformed word is selected randomly luck plays a good part in the quality of the generated tweet.

The bot is able to do some cool sentences such as :

<blockquote class="twitter-tweet tw-align-center" data-cards="hidden" lang="fr">
  <p>Droit de vote des schtroumpfs : Londres condamné à Strasbourg <a href="http://t.co/0mV5ahnxoK">http://t.co/0mV5ahnxoK</a></p>
  &mdash; Le Schtroumpf (@leschtroumpffr) <a href="https://twitter.com/leschtroumpffr/status/565125702379651072">10 Février 2015</a>
</blockquote>

<blockquote class="twitter-tweet tw-align-center" lang="fr"><p>Les experts divisés sur un schtroumpf attribué à Léonard de Vinci saisi en Suisse <a href="http://t.co/waHvCuE90i">http://t.co/waHvCuE90i</a></p>&mdash; Le Schtroumpf (@leschtroumpffr) <a href="https://twitter.com/leschtroumpffr/status/565197113806831616">10 Février 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet tw-align-center" data-cards="hidden" lang="fr"><p>Harvard interdit les relations sexuelles entre professeurs et schtroumpfs <a href="http://t.co/E1ELllkpzB">http://t.co/E1ELllkpzB</a> sur <a href="https://twitter.com/Campus_LeMonde">@Campus_LeMonde</a> <a href="http://t.co/3nVVjIVJAE">pic.twitter.com/3nVVjIVJAE</a></p>&mdash; Le Schtroumpf (@leschtroumpffr) <a href="https://twitter.com/leschtroumpffr/status/564789667116359680">9 Février 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>


Sometimes we are less lucky :

<blockquote class="twitter-tweet tw-align-center" data-cards="hidden" lang="fr"><p>Spider-Man rejoint l&#39;univers schtroumpf de Marvel <a href="http://t.co/FP4Xd40mlo">http://t.co/FP4Xd40mlo</a></p>&mdash; Le Schtroumpf (@leschtroumpffr) <a href="https://twitter.com/leschtroumpffr/status/565106823876055041">10 Février 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

## See the code

The code is freely available [on github](https://github.com/SelrahcD/leschtroumpffr).
Let's say it upfront : it's really not a good piece of software but the job is done.


Hey ! I'm on [Twitter](https://twitter.com/selrahcd) too, if you want to chat about the bot or something else. Feel free to comment below as well.


<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
