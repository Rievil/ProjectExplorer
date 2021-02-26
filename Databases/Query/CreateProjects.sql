USE [Projects]
GO

/****** Object:  Table [dbo].[Experiments]    Script Date: 25.02.2021 16:14:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
/*
DROP TABLE [dbo].[ProjectList]
Go
*/

CREATE TABLE [dbo].[ProjectList](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[ProjectName] [ntext] NULL,
	[Description] [ntext] NULL,
	[ProjectStart] [date] NULL,
	[ProjectEnd] [date] NULL,
	[LastChange] [date] NULL
)
GO

