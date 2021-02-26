USE [Projects]
GO

/****** Object:  Table [dbo].[Experiments]    Script Date: 25.02.2021 17:23:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


DROP TABLE [dbo].[Users]
GO


CREATE TABLE [dbo].[Users](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[Alias] [char] NULL,
	[UserName] [char] NULL,
	[Password] [char] NULL)
GO