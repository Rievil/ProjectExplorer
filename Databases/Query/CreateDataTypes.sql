USE [Projects]
GO

/****** Object:  Table [dbo].[Experiments]    Script Date: 25.02.2021 16:14:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
DROP TABLE [dbo].[DataTypes]
Go
*/

CREATE TABLE [dbo].[DataTypes](
	[ID] [int] NOT NULL PRIMARY KEY,
	[Name] [ntext] NULL,
	[Description] [ntext] NULL
)
GO