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
		fileType = (getFilenameType file)

		if fileType != ".sco" then
		(
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
			else if type == "anmd" then
			(
				global gAnm = importANM()
				gAnm.loadAnimation byteStream
			)
		)
		else
		(
			fileStream = openFile file mode:"rt"

			global gSco = importSCO()
			gSco.loadObject fileStream
		)
	)
)

struct importSCO (
	name,
	vertArray = #(),
	faceArray = #(),

	fn vertConvert vert =
	(
		space = filterString vert " "

		if space.count == 6 then
		(
			MessageBox("Vertex = 6")
		)
		else if space.count == 10 then
		(
			vertex = scoVertex()

			position = Point3 (space[1] as float) (space[2] as float) (space[3] as float)
			vertex.position = point3Swap position

			normal = Point3 (space[4] as float) (space[5] as float) (space[6] as float)
			vertex.normal = point3Swap normal

			tangent = Point3 (space[7] as float) (space[8] as float) (space[9] as float)
			vertex.tangent = point3Swap tangent

			vertex.vTangent = space[10] as float

			return vertex
		)
		else if space.count == 13 then
		(
			MessageBox("Vertex = 13")
		)
	),

	fn faceConvert face =
	(
		str = filterString face "\t"

		face = scoFace()
		face.name = str[3]

		vIndices = filterString str[2] " "
		face.vIndices = Point3 (vIndices[1] as float) (vIndices[2] as float) (vIndices[3] as float)

		vVertices = filterString str[4] " "
		face.v1 = #((vVertices[1] as float), (vVertices[2] as float))
		face.v2 = #((vVertices[3] as float), (vVertices[4] as float))
		face.v3 = #((vVertices[5] as float), (vVertices[6] as float))

		return face
	),

	fn loadObject fileStream =
	(
		skipToString fileStream "Name= "
		name = readLine fileStream

		skipToString fileStream "CentralPoint= "	
		centralPoint = filterString (readLine fileStream) " "
		centralPoint = point3Swap (Point3 (centralPoint[1] as float) (centralPoint[2] as float) (centralPoint[3] as float))

		skipToString fileStream "Verts= "
		verts = (readLine fileStream) as Integer
		for i = 1 to verts do
		(
			append vertArray (vertConvert (readLine fileStream))
		)

		skipToString fileStream "Faces= "
		faces = (readLine fileStream) as Integer
		for i = 1 to faces do
		(
			append faceArray (faceConvert (readLine fileStream))
		)

-- 		Create Mesh
		vertices = #()
		for vert in vertArray do
		(
			append vertices [vert.position[1], vert.position[2], vert.position[3]]
		)

		faces = #()
		tverts = #()
		for face in faceArray do
		(
			append faces [face.vIndices[1] + 1, face.vIndices[2] + 1, face.vIndices[3] + 1]
			append tverts [face.v1[1], face.v1[2], 0.0]
			append tverts [face.v2[1], face.v2[2], 0.0]
			append tverts [face.v3[1], face.v3[2], 0.0]
		)

		node = mesh vertices:vertices tverts:tverts faces:faces name:(toLower name)
		buildTVFaces node
		for i = 1 to node.numfaces do
		(
			setTVFace node i ((i * 3) - 2) ((i * 3) - 1) (i * 3) -- tverts
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

			append bone.matrix (Matrix3 r1 r2 r3 r4)
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
			return Point3 bone.matrix[2]._21 bone.matrix[2]._22 bone.matrix[2]._23 -- up
		)

		fn createBone name parent start end direction size =
		(
			if start == undefined or end == undefined or direction == undefined then
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

		for i = 1 to vertices do
		(
			wgt = wgtData()

			for i = 1 to 4 do
			(
				wgt.boneID[i] = ReadByte byteStream #unsigned
			)

			for i = 1 to 4 do
			(
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

			for i = 1 to 4 do
			(
				boneID = data.boneID[i] + 1

-- 				Normalize weights
				if ws > 1.0f then
					weight = data.weight[i] / ws
				else
					weight = data.weight[i]

				bone = gSkl.boneList[boneID]
				if bone.node != undefined then
				(
-- 					Create Weight (Erased & Retained)
					if i == 1 then
						skinOps.ReplaceVertexWeights nodeModifier vertex boneID weight
					else
						skinOps.SetVertexWeights nodeModifier vertex boneID weight
				)
			)
		)
	)
)

struct importANM (
-- 	Header
	skeletonID,
	boneLength,
	frameCount,
	fps,
-- 
	dataList = #(),

	fn loadAnimation byteStream =
	(
		skeletonID = ReadUInt byteStream
		boneLength = ReadUInt byteStream
		frameCount = ReadUInt byteStream
		fps = ReadUInt byteStream

		for i = 1 to boneLength do
		(
			anm = anmData()
			anm.name = ReadFixedString byteStream 32
			anm.flag = ReadUInt byteStream

			for i = 1 to frameCount do
			(
				frame = anmFrame()

				for i = 1 to 4 do
				(
					frame.fQuaternion[i] = ReadFloat byteStream
				)

				for i = 1 to 3 do
				(
					frame.fPosition[i] = ReadFloat byteStream
				)

				append anm.frame frame
			)

			append dataList anm
		)


-- 		Check node anim file #later

		fn getBoneByName name =
		(
			for bone in gSkl.boneList do
			(
				if bone.name == name then
					return bone
			)
			return undefined
		)

-- 		Create Animation
		with animate on
		(
-- 			Setting FPS & Frame #later
			for i = 1 to frameCount do
			(
				at time (i - 1) -- Start frame 0 in 3dsmax
				(
					for data in dataList do
					(
						bone = getBoneByName data.name
						if bone != undefined and bone.node != undefined then
						(
							position = data.frame[i].fPosition
							quaternion = data.frame[i].fQuaternion

							quaternion = Quat quaternion[1] quaternion[2] quaternion[3] quaternion[4]
							quaternion = maxtrix3Swap (quaternion as Matrix3)

							in coordsys parent bone.node.rotation = quaternion
							in coordsys parent bone.node.pos = Point3 position[1] position[3] position[2]
						)
					)
				)
			)
		)
	)
)