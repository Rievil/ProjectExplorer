USE [Projects]
GO

/****** Object:  Table [dbo].[Experiments]    Script Date: 25.02.2021 17:23:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


DROP TABLE [dbo].[UserStatus]
GO


CREATE TABLE [dbo].[UserStatus](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[Name] [char] NULL)
GO