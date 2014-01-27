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
-- Author: Jonathan Baecker (jb_alvarado) blog.pixelcrusher.de | www.pixelcrusher.de
-- Createt: 2014-01-20
--
----------------------------------------------------------------------------------------------------------------------
*/

try ( destroyDialog FilterSelection ) catch ()

rollout FilterSelection "Filter Selection" width:150 height:235
(
	local newSelection = #()
	
	groupBox grpSelectSame "Select By Same Type" pos:[10,10] width:130 height:120
		button one "Select Same WireColor" pos:[15,30] width:120 height:20
		button two "Select Same Material" pos:[15,55] width:120 height:20
		button three "Select Same Name" pos:[15,80] width:120 height:20
		button four "Select Same Type" pos:[15,105] width:120 height:20
	
	groupBox grpMinMaxSize "Select By Min/Max Size" pos:[10,140] width:130 height:85
		spinner spnMin "Min Size: " pos:[25,160] width:110 height:16 range:[0.00,1000000.00,0.00] type:#worldunits
		spinner spnMax "Max Size: " pos:[25,180] width:110 height:16 range:[0.00,1000000.00,10.00] type:#worldunits
		button btnSelect "Select Objects" pos:[15,200] width:120 height:20
	
	
	on one pressed do
	if selection.count == 1 then (
		i = $.wirecolor
		select (for o in objects where o.wirecolor == i collect o)
		) else (
			messageBox "Select one object please" Title: "Selection Error..."
			)

	on two pressed do
	if selection.count == 1 then (
		i = $.material
		select (for o in objects where o.material == i collect o)
		) else (
			messageBox "Select one object please" Title: "Selection Error..."
			)

	on three pressed do
	if selection.count == 1 then (
		nam = selection[1]
		sel = filterstring nam.name ",;.:-_+/\#0123456789"
		objs = objects as array
		selArray = #()
		for i = 1 to objs.count do(
			objsName = filterstring objs[i].name ",;.:-_+/\#0123456789"
				if (objsName[1] == sel[1]) do (
					join selArray #(objs[i])
					)
			) 
		select selArray
		) else (
			messageBox "Select one object please" Title: "Selection Error..."
			)	

	on four pressed do
	if selection.count == 1 then (
		sel = selection[1]
		obj = objects as array
		selArray = #()
		
		for i = 1 to obj.count do (
			if (superclassof obj[i] == superclassof sel) do (
				join selArray #(obj[i])
				)
			)
		select selArray
		) else (
			messageBox "Select one object please" Title: "Selection Error..."
			)	
		
	
	on btnSelect pressed do (
	 	selg = for o in geometry where not o.isHiddenInVpt and not o.isFrozen collect o
		newSelection = #()
		for i = 1 to selg.count do (
			objMin = selg[i].min
			objMax = selg[i].max
			objX = ( objMax.x - objMin.x )
			objY = ( objMax.y - objMin.y )
			objZ = ( objMax.z - objMin.z )
			
			if ( objX > spnMin.value AND objY > spnMin.value AND objZ > spnMin.value ) do (
				if ( objX < spnMax.value AND objY < spnMax.value AND objZ < spnMax.value ) do (
					join newSelection #( selg[i] )
					)
				)
			)
		select newSelection
		)
	)
	

createDialog FilterSelection style:#(#style_toolwindow, #style_border, #style_sysmenu)
