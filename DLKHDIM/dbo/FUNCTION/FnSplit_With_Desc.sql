CREATE FUNCTION [dbo].[FnSplit_With_Desc]
(
@List nvarchar(max),
@SplitOn nvarchar(5),
@Id int,
@Desc nvarchar(100)
)  
RETURNS @RtnValue table 
(

Id int identity(1,1),
Value nvarchar(100),
Key_Id int,
Description nvarchar(100)
) 
AS  
BEGIN
While (Charindex(@SplitOn,@List)>0)
Begin 
Insert Into @RtnValue (value,Key_Id,Description)
Select
Value = ltrim(rtrim(Substring(@List,1,Charindex(@SplitOn,@List)-1))),KEY_ID=@Id,Description=@Desc
Set @List = Substring(@List,Charindex(@SplitOn,@List)+len(@SplitOn),len(@List))
End 

Insert Into @RtnValue (Value,Key_Id,Description)
Select Value = ltrim(rtrim(@List)),KEY_ID=@Id,Description=@Desc
Return
END
