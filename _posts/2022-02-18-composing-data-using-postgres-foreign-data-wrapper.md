---
layout: "post-no-feature"
title: "Composing data using Postgres Foreign Data Wrapper"
description: "Composing data from several databases can be tricky, even worse if we need to do some paging, filtering and sorting. PostgreSQL comes with an extension making our life easier by creating remote table: tables based on a table from another server."
image: /images/22022-02-18-composing-data-using-postgres-foreign-data-wrapper/carbon.png
category: articles
tags:
 - postgres
 - database
 - microservices
published: true
comments: true
---
Say you decided to go the micro-service way, split your database into pieces, and are now requested a feature that needs to display data stored from several of these databases. Fetching the data from several sources and composing it somehow is a totally valid solution. Unfortunately, it starts to be tricky if you need to do some paging, sorting, and filtering based on the data from several of the databases. A solution to this problem could be to denormalize data, create some data store just for that purpose and copy the relevant data there.

A more accessible alternative solution is available if you're using PostgreSQL: thanks to the Foreign Data Wrapper extension, one Postgres database can query tables from another database as if they were on the same server.


## Displaying race results for my pony club

Let's imagine that I'm currently contracting for a Pony Club. They're really into IT and decided to build a system with two microservices. The first one knows about the club's ponies, the second one stores their results during some competitions. It would be so nice to display our ponies' results alongside some information about them, and why not do some filtering.

First let's create our two service databases.

```text
version: '3.5'

services:
  postgres_ponies:
    image: postgres
    container_name: ponies_db
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"

  postgres_race_results:
    image: postgres
    container_name: race_results_db
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5433:5432"
```

This docker compose file will start two Postgres databases, one named `ponies_db` and the other one `race_results_db`. 

We will then create some tables and add data to the two instances.

Once connected to the `ponies_db`, with `docker exec -ti ponies_db psql -U postgres` run the two following queries:

```sql
  CREATE TABLE IF NOT EXISTS ponies (
   id serial PRIMARY KEY,
   name VARCHAR ( 50 ) UNIQUE NOT NULL,
   status INT NOT NULL DEFAULT 0);

   INSERT INTO ponies(name, status) VALUES
 ('Noisette', 1),
 ('Griotte', 2),
 ('Eole', 0);
```

Here we created a `ponies` table and inserted three ponies, with an id, a name, and some status stored as an integer.


In the `race_results_db`, that you can connect to with `docker exec -ti race_results psql -U postgres`, run:

```sql
CREATE TABLE IF NOT EXISTS race_results (
   id serial PRIMARY KEY,
   race VARCHAR ( 50 ) NOT NULL,
   pony INT NOT NULL,
   timing INT NOT NULL);


INSERT INTO race_results(race, pony, timing) VALUES
('Fun fun', 1, 137),
('Fun fun', 2, 125),
('Fun fun', 3, 133),
('Epic party race', 2, 79),
('Epic party race', 3, 77);
```

This just created a `race_results` table, each row being an id, a race name as a string, a pony - an integer, mapping to the id of a pony in the `ponies_db` database, and some timing in the second.

Now, let's create the link between the two databases.

Still in the `race_results` database install the `postgres_fdw` extension:

```sql
CREATE EXTENSION IF NOT EXISTS postgres_fdw;
```

Declare a remote server, pointing to the `ponies_db` server:

```sql
CREATE SERVER ponies
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'ponies_db', port '5432');
```

and tell which user to use for the connection:

```sql
CREATE USER MAPPING FOR USER
SERVER ponies
OPTIONS (user 'postgres', password 'postgres');
```

At this point, we can create a remote table, mapping from the `ponies'table from the `ponies_db` database:

```sql
CREATE FOREIGN TABLE ponies (
  id serial,
  name VARCHAR ( 50 ),
  status INT)
SERVER ponies
OPTIONS (schema_name 'public', table_name 'ponies');
```

And now we can run a query with a join between race results and ponies, using the newly created foreign table:

```
sql
SELECT p.id, p.name, r.race, r.timing, p.status
FROM race_results r
JOIN ponies p ON r.pony = p.id;
```

```text
1,Noisette,Fun fun,137,1
2,Griotte,Epic party race,79,2
2,Griotte,Fun fun,125,2
3,Eole,Epic party race,77,0
3,Eole,Fun fun,133,0
```

## But, but, but... the coupling

You might be mumbling something about how nice that's solution is, but it creates some coupling with the schema of the `ponies_db`, and you'd be right. If the team working around the `ponies_db` feels the need to rename a column or change how they handle their statuses, it will break everything.

Fortunately, we can create foreign tables based on views. This is really nice as it means the `ponies_db` team can have an abstraction layer to hide their schema behind. If at some point they decide to change a part of the schema, as long as they modify the view to ensure not to break the contract, everything will keep running.

Furthermore, having a view helps expose a better API. So far, we don't know what the integer pony statuses mean. In the new view, we can map each value to a string, increasing the understandability of the API.

Let's make the changes.

In the `ponies_db`, we create a `public_ponies` view based on the `ponies` table:

```sql
CREATE VIEW public_ponies AS
    SELECT
           id,
           name,
           CASE status
               WHEN 0 THEN 'resting'
               WHEN 1 THEN 'available'
               WHEN 2 THEN 'injured'
           END AS status
    FROM ponies;
```

In the `race_results_db` we will remove the existing remote table and create a new one based on the view:
```sql
    DROP FOREIGN TABLE ponies;

    CREATE FOREIGN TABLE ponies (
    id serial,
    name VARCHAR ( 50 ),
    status VARCHAR)
    SERVER ponies
    OPTIONS (schema_name 'public', table_name 'public_ponies');
```

Now, we can rerun our query with the join:

```sql
SELECT p.id, p.name, r.race, r.timing, p.status
FROM race_results r
JOIN ponies p ON r.pony = p.id;
```

and we will get 

```text
1,Noisette,Fun fun,137,available
2,Griotte,Epic party race,79,injured
2,Griotte,Fun fun,125,injured
3,Eole,Epic party race,77,resting
3,Eole,Fun fun,133,resting
```


## Limitations

While this solution allows doing powerful things without much work, it's not magical. The two databases need to talk to each other and exchange data which means that if they are far away from one the other, the query will take more time than if the data was all on the same server. Depending on your use case, it might be an issue or not. In the case of an asynchronous job, it's probably not; for a synchronous query, you'll have to see for yourself. Nevertheless, it would still be a decent solution to have while you're creating a read database aggregating all the data.
