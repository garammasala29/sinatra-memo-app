# Memo
 Sinatraで作成したシンプルなメモアプリです。

## DEMO
![memo-app](https://user-images.githubusercontent.com/69446373/127446256-eaafe671-a256-4b9c-865a-ec9e69b45af5.gif)

# Features

- メモの登録、編集、削除ができます

# Requirement

* ruby    2.7.2
* bundler 2.1.4

# Installation

データベースはPostgreSQLを使用しています。
データベース名は``memo_app``、テーブルは``memos``です。
```sql
% create database memo_app;
% create table memos
(
id serial NOT NULL PRIMARY KEY,
title varchar(255) NOT NULL,
content text,
created_at date NOT NULL,
updated_at date NOT NULL
);
```

```bash
% git clone https://github.com/garammasala29/sinatra-memo-app.git
% cd sinatra-memo-app
% bundle install
% bundle exec ruby app.rb
```

http://localhost:4567 こちらにアクセスし利用開始です。

# Author

* 作成者 garammasala
