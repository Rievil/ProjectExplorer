USE [Projects]
GO

/****** Object:  Table [dbo].[Experiments]    Script Date: 25.02.2021 17:23:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
DROP TABLE [dbo].[UsersOnProjects]
GO
*/

CREATE TABLE [dbo].[UsersOnProjects](
	[ID] [int] NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[StatusID] [int] NOT NULL,
	[ProjectUserID] [int] NOT NULL,	
	CONSTRAINT [ProjectUserID] FOREIGN KEY([ProjectUserID]) REFERENCES [dbo].[Users] ([ID]) ON DELETE CASCADE,
	CONSTRAINT [StatusID] FOREIGN KEY([StatusID]) REFERENCES [dbo].[UserStatus] ([ID]) ON DELETE CASCADE)
GO