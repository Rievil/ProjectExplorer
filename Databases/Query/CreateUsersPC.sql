USE [Projects]
GO

/****** Object:  Table [dbo].[Experiments]    Script Date: 25.02.2021 17:23:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


DROP TABLE [dbo].[UsersPC]
GO

CREATE TABLE [dbo].[UsersPC](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[UserID] [int] NOT NULL,
	[PCName] [char] NULL,
	[MasterFolder] [char] NULL,
	[SandboxFolder] [char] NULL,
	CONSTRAINT [UserID] FOREIGN KEY([UserID]) REFERENCES [dbo].[Users] ([ID]) ON DELETE CASCADE)
GO