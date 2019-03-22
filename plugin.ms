filein "import.ms"

GUI = newRolloutFloater "Infestation GUI" 200 250

rollout importRollout "Import (SKL, WGT, ANIM)"
(
	global gImport = import()

	button btnImportSco "Import All" tooltip:"Import .SCO" enabled: false
	button btnImportSkl "Import Skeleton" tooltip:"Import .SKL"
	button btnImportWgt "Import Mesh Weight" tooltip:"Import .WGT" enabled: false
	button btnImportAnim "Import Animation" tooltip:"Import .ANIM" enabled: false
	
	on btnImportSkl pressed do
	(
		file = getOpenFileName caption:"Import SKL file" types:"Skeleton (*.skl)|*.skl"
		if file != undefined then (
			gImport.loadFile file
			btnImportWgt.enabled = true -- test
		)
	)
	
	on btnImportWgt pressed do
	(
		file = getOpenFileName caption:"Import WGT file" types:"Mesh Weight (*.wgt)|*.wgt"
		if file != undefined then (
			gImport.loadFile file
		)
	)
)

addRollout importRollout GUI