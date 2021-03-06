/****** Object:  Table [dbo].[TB_PARAMETRO]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_PARAMETRO](
	[ID_PARAMETRO] [int] IDENTITY(1,1) NOT NULL,
	[NM_PARAMETRO] [varchar](50) NOT NULL,
	[VALOR] [varchar](150) NULL,
	[CREATED_BY] [varchar](100) NOT NULL,
	[CREATED_DATE] [datetime2](7) NOT NULL,
	[LAST_MODIFIED_BY] [varchar](100) NULL,
	[LAST_MODIFIED_DATE] [datetime2](7) NULL,
 CONSTRAINT [PK__PARAMETRO] PRIMARY KEY CLUSTERED 
(
	[ID_PARAMETRO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]