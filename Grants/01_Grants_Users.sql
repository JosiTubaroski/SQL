
EXEC SP_SRVROLEPERMISSION 'bulkadmin'

-- Criação de um banco para nossos testes
CREATE DATABASE RoleTest
GO

USE RoleTest
GO

--Tabela pra teste

CREATE TABLE dbo.Roles(
linha INT NULL,
nome VARCHAR(20) NULL,
descricao VARCHAR(100) NULL)

select * from dbo.Roles

-- Criação dos logins para teste
USE MASTER
GO
-- Esse cara foi eleito BulkAdmin pela comissão oficial dos databases do brasil
CREATE LOGIN CarinhaBulkAdmin WITH PASSWORD = 'bulkadmin1', CHECK_POLICY = OFF;

-- Adiciona o login à role Bulkadmin
EXEC sp_addsrvrolemember 'CarinhaBulkAdmin', 'bulkadmin';

--Esse cara terá permissão de inserção e nada mais (nem arquivo externo)
CREATE LOGIN CarinhaDoInsert WITH PASSWORD = 'insert1', CHECK_POLICY = OFF;

/* Criando usuários para ambos os logins na base */

USE RoleTest

EXEC sp_addsrvrolemember CarinhaDoInsert, 'bulkadmin'

--O usuário foi criado. Lembrando: ele tem role de servidor Bulkadmin
CREATE USER usrBulkInsert FOR LOGIN CarinhaBulkAdmin

-- O usuário que só pode inserir e não pode fazer bulk insert
CREATE USER usrInsert FOR LOGIN CarinhaDoInsert

-- Ou seja...O único que tem permissão de Insert é o usrInsert
GRANT INSERT ON Object::dbo.Roles TO usrInsert

GRANT select ON Object::dbo.Roles TO usrBulkInsert

--- Logando com o carinha

USE RoleTest
GO
-- Insert deve funcionar normalmente.
INSERT INTO dbo.Roles (linha,nome,descricao) VALUES (0,'bulkadm','Começo de teste')
-- Agora tente dar um BULK INSERT sem ter permissão...
BULK INSERT dbo.Roles 
FROM 'C:\temp\carga.txt' WITH  (FIELDTERMINATOR = ',',   
ROWTERMINATOR   = 'n')

select * from dbo.Roles
