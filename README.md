# Alimentacao-Sql-com-CSV-massivo
Atividades feitas em sala, com intuito de alimentar, tratar e fazer exercícios com JOIN em SQL em um CSV com mais de 112 mil linhas.

Foi utilizado ferramentas online para tratar o .csv para deixar ele com 1000 registros, criando um novo csv (file0.csv).

Criado o banco de dados, e alimentado via LOAD DATA FILE, para cada uma das tabelas, e depois foi feita uma importação direta do .csv em uma tabela temporária, para tratar os dados relacionados para a tabela principal.
Isso serviu para transportar as relações de cada registro individualmente, e que todos tenham seus IDs linkados com cada tabela. Também quando alimentados, utilizei @dummy para evitar as colunas que não seriam tratadas no caso.
Por isso, foi na tentativa e erro que o banco de dados foi alimentado. Foi utilizado TRUNCATE para limpar as tabelas.

Todas as tabelas contém a restraint UNIQUE, onde filtrou os dados para não ficarem com número de IDs indesejadamente altos. 

Cada view criada foi separada no final do arquivo, para cada exercício.
