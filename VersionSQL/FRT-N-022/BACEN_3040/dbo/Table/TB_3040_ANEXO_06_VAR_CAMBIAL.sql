/****** Object:  Table [dbo].[TB_3040_ANEXO_06_VAR_CAMBIAL]    Committed by VersionSQL https://www.versionsql.com ******/

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[TB_3040_ANEXO_06_VAR_CAMBIAL](
	[ID_ANEXO_06] [int] IDENTITY(1,1) NOT NULL,
	[CD_VAR_CAMBIAL] [varchar](3) NOT NULL,
	[DS_VAR_CAMBIAL] [varchar](15) NOT NULL,
	[IS_ATIVO] [bit] NOT NULL,
	[CREATED_BY] [varchar](100) NOT NULL,
	[CREATED_DATE] [datetime2](7) NOT NULL,
	[LAST_MODIFIED_BY] [varchar](100) NOT NULL,
	[LAST_MODIFIED_DATE] [datetime2](7) NOT NULL,
 CONSTRAINT [PK__ANEXO_06] PRIMARY KEY CLUSTERED 
(
	[ID_ANEXO_06] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]