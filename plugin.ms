filein "import.ms"

GUI = newRolloutFloater "InfestMS" 225 375

rollout importRollout "Import"
(
	global gImport = import()

	button btnImportAll "Import All" tooltip:"Import SCO, SKL, WGT" enabled:false
	button btnImportSco "Import SCO" tooltip:"Import SCO" enabled:false
	button btnImportSkl "Import Skeleton" tooltip:"Import SKL"
	button btnImportWgt "Import Mesh Weight" tooltip:"Import WGT" enabled:false
	button btnImportAnim "Import Animation" tooltip:"Import ANM" enabled:false
	
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

rollout exportRollout "Export"
(
	button btnExportAll "Export All" tooltip:"Export SCO, SKL, WGT" enabled:false
	button btnExportSco "Export SCO" tooltip:"Export SCO" enabled:false
	button btnExportSkl "Export Skeleton" tooltip:"Export SKL" enabled:false
	button btnExportWgt "Export Mesh Weight" tooltip:"Export WGT" enabled:false
	button btnExportAnim "Export Animation" tooltip:"Export ANM" enabled:false
)

rollout importOtRollout "Import options"
(
	checkbox dummyChecked "Dummy" tooltip:"Dummy (Enable / Disable)" enabled:false
)

addRollout importRollout GUI
addRollout importOtRollout GUI
addRollout exportRollout GUI