USE [Projects]
GO

/****** Object:  Table [dbo].[Experiments]    Script Date: 25.02.2021 17:23:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


DROP TABLE [dbo].[Experiments]
Go

CREATE TABLE [dbo].[Experiments](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[ProjectID] [int] NOT NULL,
	[Name] [ntext] NULL,
	[Description] [ntext] NULL,
 CONSTRAINT [ProjectID] FOREIGN KEY([ProjectID]) REFERENCES [dbo].[ProjectList] ([ID]) ON UPDATE CASCADE)
GO

