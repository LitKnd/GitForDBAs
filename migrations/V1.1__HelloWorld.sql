CREATE TABLE HelloWorld (
    HelloWorldId INT IDENTITY NOT NULL,
    Declaration nvarchar(1000) NULL,
    CONSTRAINT PK_HelloWorld PRIMARY KEY CLUSTERED (HelloWorldId)
);

