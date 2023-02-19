# README
### 実装方針
- DB
  - PostgreSQLを使用する。
    - サーバーサイドをKtorに置き換える可能性があるので、テーブル間のリレーションはActiveRecordの機能のみならず、referenceを使ったリレーションも使う。
    - かつ、Rails内での可読性もあげるため、has_oneやhas_manyなどの独自の機能も使っていく。
