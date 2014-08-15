/*
----------------------------------------------------------------------------------------------------------------------
::
:: Description: This MaxScript is for selection objects by different filter types
::
----------------------------------------------------------------------------------------------------------------------
:: LICENSE ----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
::
:: Copyright (C) 2014 Jonathan Baecker (jb_alvarado)
::
:: This program is free software: you can redistribute it and/or modify
:: it under the terms of the GNU General Public License as published by
:: the Free Software Foundation, either version 3 of the License, or
:: (at your option) any later version.
::
:: This program is distributed in the hope that it will be useful,
:: but WITHOUT ANY WARRANTY; without even the implied warranty of
:: MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
:: GNU General Public License for more details.
::
:: You should have received a copy of the GNU General Public License
:: along with this program. If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------
:: History --------------------------------------------------------------------------------------------------------
:: 2014-01-20 writing script
----------------------------------------------------------------------------------------------------------------------
::
::
----------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------
--
-- Filter Selection v 0.85
-- Author: Jonathan Baecker (jb_alvarado) blog.pixelcrusher.de | www.pixelcrusher.de | www.animations-and-more.com
-- Createt: 2014-01-20
--
----------------------------------------------------------------------------------------------------------------------
*/

macroScript FilterSelection
 category:"jb_scripts"
 ButtonText:"FilterSelection"
 Tooltip:"Filter Object Selection By Different Types"
(
global FilterSelection
try ( destroyDialog FilterSelection ) catch ()

rollout FilterSelection "Filter Selection" width:150 height:260
(
	local newSelection = #()
	
	groupBox grpSelectSame "Select By Same Type" pos:[10,10] width:130 height:145
		button selWire "Select Same WireColor" pos:[15,30] width:120 height:20
		button selMat "Select Same Material" pos:[15,55] width:120 height:20
		button selNam "Select Same Name" pos:[15,80] width:120 height:20
		button seltyp "Select Same Type" pos:[15,105] width:120 height:20
		button selSiz "Select Same Size" pos:[15,130] width:120 height:20
	
	groupBox grpMinMaxSize "Select By Min/Max Size" pos:[10,165] width:130 height:85
		spinner spnMin "Min Size: " pos:[25,185] width:110 height:16 range:[0.00,1000000.00,0.00] type:#worldunits
		spinner spnMax "Max Size: " pos:[25,205] width:110 height:16 range:[0.00,1000000.00,10.00] type:#worldunits
		button btnSelect "Select Objects" pos:[15,225] width:120 height:20
	
	fn selFn selArray = (
		undo "FilterSelection" on (
			for obj in selArray where isGroupMember obj AND ( NOT isOpenGroupMember obj ) do (
				par = obj.parent
				while par != undefined do (
					if isGroupHead par then (
						setGroupOpen par true
						par = undefined
						) else (
							par = par.parent
							)
					)
				)
				
				selcount = #()
				for o in selArray where not( o.layer.on ) do o.layer.on = true
				for o in selArray where o.layer.isFrozen do o.layer.isFrozen = false
				--for o in selArray where o.isHidden do o.isHidden = true
				for o in selArray where o.isFrozen do o.isFrozen = false
				select selArray
			)
		)
		
	on selWire pressed do
	if selection.count == 1 then (
		i = $.wirecolor
		selArray = for o in objects where o.wirecolor == i and o.isHidden == false and not o.isFrozen collect o
		selFn selArray
		) else (
			messageBox "Select one object please" Title: "Selection Error..."
			)

	on selMat pressed do
	if selection.count == 1 then (
		i = $.material
		selArray = for o in objects where o.material == i and o.isHidden == false and not o.isFrozen collect o
		selFn selArray
		) else (
			messageBox "Select one object please" Title: "Selection Error..."
			)

	on selNam pressed do
	if selection.count == 1 then (
		nam = selection[1]
		sel = filterstring nam.name ",;.:-_+/\#0123456789"
		objs = objects as array
		selArray = #()
		for i = 1 to objs.count do (
			objsName = filterstring objs[i].name ",;.:-_+/\#0123456789"
				if (objsName[1] == sel[1]) and objs[i].isHidden == false do (
					join selArray #(objs[i])
					)
			)
		selFn selArray
		) else (
			messageBox "Select one object please" Title: "Selection Error..."
			)	

	on seltyp pressed do
	if selection.count == 1 then (
		sel = selection[1]
		obj = objects as array
		selArray = #()
		
		for i = 1 to obj.count do (
			if (superclassof obj[i] == superclassof sel) and obj[i].isHidden == false do (
				join selArray #(obj[i])
				)
			)
		selFn selArray
		) else (
			messageBox "Select one object please" Title: "Selection Error..."
			)	
		
	on selSiz pressed do (
		if selection.count == 1 then (
			sel = selection[1]
			obj = objects as array
			selArray = #()
			bound = nodeGetBoundingBox sel sel.transform
			selSize = ( bound[2] - bound[1] )
			selX = dotNetObject "System.Double" ( selSize.x )
			selY = dotNetObject "System.Double" ( selSize.y )
			selZ = dotNetObject "System.Double" ( selSize.z )
			
			selXRes = ((dotNetClass "System.Math").round selX 2) as float
			selYRes = ((dotNetClass "System.Math").round selY 2) as float
			selZRes = ((dotNetClass "System.Math").round selZ 2) as float
			selRes = selXRes + selYRes + selZRes
			for i = 1 to obj.count do (
				bound = nodeGetBoundingBox obj[i] obj[i].transform
				objSize = ( bound[2] - bound[1] )
				objX = dotNetObject "System.Double" ( objSize.x )
				objY = dotNetObject "System.Double" ( objSize.y )
				objZ = dotNetObject "System.Double" ( objSize.z )

				objXRes = ((dotNetClass "System.Math").round objX 2) as float
				objYRes = ((dotNetClass "System.Math").round objY 2) as float
				objZRes = ((dotNetClass "System.Math").round objZ 2) as float
				objRes = objXRes + objYRes + objZRes
				if (objRes == selRes) and obj[i].isHidden == false do (
					join selArray #( obj[i] )
					)
				)
			selFn selArray	
			) else (
				messageBox "Select one object please" Title: "Selection Error..."
				)
		)	
	
	on btnSelect pressed do (
		selg = for o in geometry where not o.isHiddenInVpt and not o.isFrozen collect o
		selArray = #()
		for i = 1 to selg.count do (
			
			bound = nodeGetBoundingBox selg[i] selg[i].transform
			dim = ( bound[2] - bound[1] )
			
			if ( dim.x > spnMin.value AND dim.y > spnMin.value AND dim.z > spnMin.value ) do (
				if ( dim.x < spnMax.value AND dim.y < spnMax.value AND dim.z < spnMax.value ) do (
					join selArray #( selg[i] )
					)
				)
			)
		selFn selArray
		)
	)
	

createDialog FilterSelection style:#(#style_toolwindow, #style_border, #style_sysmenu)
cui.RegisterDialogBar FilterSelection minSize:[150, 260] maxSize:[150, 265] style:#(#cui_dock_vert, #cui_floatable, #cui_handles)
	
)
