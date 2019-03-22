fileIn "utils.ms"
fileIn "structs.ms"

struct import
(
	r3d,
	type,
	version,

	fn loadFile file =
	(
		fileName = (getFilenameFile file)
		byteStream = fopen file "rb"

		r3d = ReadFixedString byteStream 4
		type = ReadFixedString byteStream 4
		version = ReadUInt byteStream

		if r3d != "r3d2" and version != 1 then
		(
			MessageBox("Wrong header file.")
			return false
		)

		if type == "sklt" then
		(
			global gSkl = importSKL()
			gSkl.loadSkeleton byteStream
		)
		else if type == "wght" then
		(
			global gWgt = importWGT()
			gWgt.loadWeight fileName byteStream
		)
	)
)

struct importSKL
(
-- 	Header
	skeletonID,
	boneLength,
-- 	
	dataList = #(),
	boneList = #(),

	fn loadSkeleton byteStream =
	(
		skeletonID = ReadUInt byteStream
		boneLength = ReadUInt byteStream

		for i = 1 to boneLength do
		(
			skl = sklData()
			skl.name = ReadFixedString byteStream 32
			skl.parentID = ReadUInt byteStream
			skl.fLength = readFloat byteStream

			for i = 1 to 12 do
			(
				if i <= 4 then
					skl.c1[i] = readFloat byteStream
				else if i <= 8 then
					skl.c2[i - 4] = readFloat byteStream
				else if i <= 12 then
					skl.c3[i - 8] = readFloat byteStream
			)

			append dataList skl
		)

		for skl in dataList do
		(
			bone = sklBone()
			bone.name = skl.name
			bone.parentID = skl.parentID
			bone.fLength = skl.fLength

			-- Z up Y
			c1 = Point4 skl.c1[1] skl.c1[2] skl.c1[3] skl.c1[4]
			c2 = Point4 skl.c3[1] skl.c3[2] skl.c3[3] skl.c3[4]
			c3 = Point4 skl.c2[1] skl.c2[2] skl.c2[3] skl.c2[4]

			-- Row3 up Row2
			r1 = Point3 c1[1] c2[1] c3[1]
			r2 = Point3 c1[3] c2[3] c3[3]
			r3 = Point3 c1[2] c2[2] c3[2]
			r4 = Point3 c1[4] c2[4] c3[4]

			append bone.matrix (Matrix3 r1 r2 r3 r4)

			m = sklMatrix()
			m._11 = c1[1]
			m._21 = c1[2]
			m._31 = c1[3]
			m._41 = c1[4]
			m._12 = c2[1]
			m._22 = c2[2]
			m._32 = c2[3]
			m._42 = c2[4]
			m._13 = c3[1]
			m._23 = c3[2]
			m._33 = c3[3]
			m._43 = c3[4]

			append bone.matrix m

			append boneList bone
		)

		fn getBoneByName name =
		(
			for bone in boneList do
			(
				if bone.name == name then
					return bone
			)
			return undefined
		)

		fn getOrigin bone =
		(
			v1 = bone.matrix[1].translation
			v3 = Point3 bone.matrix[2]._11 bone.matrix[2]._12 bone.matrix[2]._13 -- right
			fLen = bone.fLength / 2
			origin = v1 + (Point3 (v3[1] * fLen) (v3[2] * fLen) (v3[3] * fLen))
			return origin
		)

		fn getDirection bone =
		(
		   return Point3 bone.matrix[2]._11 bone.matrix[2]._12 bone.matrix[2]._13
		)

		fn createBone name parent start end direction size =
		(
			if start == undefined or start == undefined or direction == undefined then
				return undefined

			node = BoneSys.createBone start end direction
			node.Name = name
			if parent != undefined then
				node.parent = parent
			node.Width = size
			node.Height = size
			return node
		)

-- 		Create Bone
		nodeGroup = #()
		for i = 1 to boneList.count do
		(
			bone = boneList[i]

			if bone.parentID == -1 then
			(
				nodeGroup[i] = createBone bone.name undefined bone.matrix[1].translation bone.matrix[1].translation (getDirection bone) 0.0
			)
			else
			(
				nodeGroup[i] = createBone bone.name nodeGroup[bone.parentID + 1] bone.matrix[1].translation (getOrigin bone) (getDirection bone) 0.01
			)

			bone.node = nodeGroup[i]
		)

-- 		Create Dummy
		for bone in boneList do
		(
			pt = point name:(bone.name + "_Dummy") size:0.025 Box:on cross:off drawontop:on
			pt.transform = bone.node.transform
			pt.parent = bone.node
			if bone.parentID == -1 then
				pt.wirecolor = red
			else
				pt.wirecolor = green
		)
	)
)

struct importWGT (
-- 	Header
	skeletonID,
	vertices,
-- 
	dataList = #(),

	fn loadWeight fileName byteStream =
	(
		skeletonID = ReadUInt byteStream
		vertices = ReadUInt byteStream

		for i = 1 to vertices do (
			wgt = wgtData()

			for i = 1 to 4 do (
				wgt.boneID[i] = ReadByte byteStream #unsigned
			)

			for i = 1 to 4 do (
				wgt.weight[i] = ReadFloat byteStream
			)

			append dataList wgt
		)

		fn getBoneIDByName name =
		(
			for i = 1 to gSkl.boneList.count do
			(
				if gSkl.boneList[i].name == name then
					return i
			)
			return undefined
		)

-- 		Create Weight
		node = getNodeByName fileName

		if node == undefined then
		(
			MessageBox ("Not found \"" + fileName + "\"")
			return false
		)

		if node.verts.count != vertices then
		(
			MessageBox ("Vertex not match")
			return false
		)

		if GetCommandPanelTaskMode() != #modify then
			SetCommandPanelTaskMode #modify
		
		addModifier node (Skin())
		nodeModifier = node.modifiers[#Skin]
		modPanel.setCurrentObject nodeModifier
		for bone in gSkl.boneList do
		(
			skinOps.AddBone nodeModifier bone.node 1
		)
		modPanel.setCurrentObject nodeModifier

		for i = 1 to dataList.count do
		(
			vertex = i
			data = dataList[i]

			ws = 0.0f
			for i = 1 to 4 do
			(
				ws += data.weight[i]
			)

			array = #(#(), #())
			for i = 1 to 4 do
			(
				boneID = data.boneID[i] + 1

-- 				Normalize weights
				if ws > 1.0f then
					weight = data.weight[i] / ws
				else
					weight = data.weight[i]

-- 				Swap bone L to R (wrong in vertex or wtf?)
				bone = gSkl.boneList[boneID]
				if (iL = (findString bone.name "_L_")) != undefined then
					boneID = getBoneIDByName (replace bone.name iL 3 "_R_")
				else if (iR = (findString bone.name "_R_")) != undefined then
					boneID = getBoneIDByName (replace bone.name iR 3 "_L_")

				append array[1] boneID
				append array[2] weight
			)

			skinOps.ReplaceVertexWeights nodeModifier vertex array[1] array[2]
		)
	)
)