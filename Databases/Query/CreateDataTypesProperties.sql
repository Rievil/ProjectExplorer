USE [Projects]
GO

/****** Object:  Table [dbo].[Experiments]    Script Date: 25.02.2021 17:23:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
DROP TABLE [dbo].[Experiments]
Go
*/


CREATE TABLE [dbo].[DataTypesProperties](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[DataTypeID] [int] NOT NULL,
	[Property] [varchar] NOT NULL,
	[Value] [varchar] NULL,
	[Type] [varchar] NULL,
 CONSTRAINT [DataTypeID] FOREIGN KEY([DataTypeID]) REFERENCES [dbo].[DataTypes] ([ID]) ON DELETE CASCADE)
GO