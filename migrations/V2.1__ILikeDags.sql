CREATE TABLE ILikeDags (
    ILikeDagsId INT IDENTITY NOT NULL,
    Declaration nvarchar(1000) NULL,
    CONSTRAINT PK_ILikeDags PRIMARY KEY CLUSTERED (ILikeDagsId)
);
