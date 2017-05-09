[contactFullName] = convert(nvarchar(200), [firstName] + ' ' [lastName]),
[salesPersonAlias] = cast(substring([salesPerson], patIndex(%/%, [salesPerson]) + 1， 256）as nvarchar(200))
--substring(在哪搞，起点，搞多长）
--patindex(%标记%，在哪搞） 给出标记的index位置 楼上指的是从标记出+1开始搞 去掉‘/’
--cast([column] as type)
--convert(type, [column])
 