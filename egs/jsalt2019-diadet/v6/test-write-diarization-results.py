


with open('exp/results.txt', 'r') as fin:
	with open('exp/results-final.csv', 'w') as fout:
		lines = fin.readlines()
		for line in lines:
			line = line.strip()
			split = line.split(',')
			nn_name = split[0]
			plda = split[1]
			
			dset_dir_split = split[2].split('_')
			corpus = dset_dir_split[0]
			dset_dir_split.remove(corpus)
			
			enhanced = 'nonEnh'
			if 'enhanced' in dset_dir_split:
				enhanced = 'enh'
				dset_dir_split.remove('enhanced')
			
			partition = 'dev'
			if 'eval' in dset_dir_split:
				partition = 'eval'
				dset_dir_split.remove('eval')
			else:
				dset_dir_split.remove('dev')

			vad = 'pyvad'
			if 'gtvad' in dset_dir_split:
				vad = 'gtvad'
				dset_dir_split.remove('gtvad')
			elif 'evad' in dset_dir_split:
				vad = 'evad'
				dset_dir_split.remove('evad')

			recluster=''
			if 'VaBclustering' in dset_dir_split:
				recluster='VB cluster'
				dset_dir_split.remove('VaBclustering')
				
			reseg = ''
			if 'VB' in dset_dir_split:
				reseg = 'VB'
				dset_dir_split.remove('VB')
			elif 'VB10' in dset_dir_split:
				reseg = 'VB10'
				dset_dir_split.remove('VB10')				
			elif 'VBvoxceleb' in dset_dir_split:
				reseg = 'VBvoxceleb'
				dset_dir_split.remove('VBvoxceleb')
			elif 'VBvoxceleb10' in dset_dir_split:
				reseg = 'VBvoxceleb10'
				dset_dir_split.remove('VBvoxceleb10')
			elif 'resLSTM' in dset_dir_split:
				reseg = 'resLSTM'
				dset_dir_split.remove('resLSTM')				

			ovl_assign=''
			if 'OVLassign' in dset_dir_split:
				ovl_assign = 'OVLassignVB'
				dset_dir_split.remove('OVLassign')
			elif 'ovlLSTM' in dset_dir_split:
				ovl_assign = 'ovlLSTM'
				dset_dir_split.remove('ovlLSTM')

			

			if len(dset_dir_split) > 1:
				print("Careful! ... It looks like you haven't parsed all options for the line.")
				print("Skipping this line. \n {} \n".format(line))
				print("Remaining split: {}".format(dset_dir_split))
				continue
			elif dset_dir_split:
				mic = ''.join(dset_dir_split)
			else:
				mic = 'NA'
			
			try: 
				der = split[3]
				miss = split[4]
				FA = split[5]
				confusion = split[6]
			except IndexError:
				print("There was an index error.")
				print("Skipping this line. \n {}".format(line))			
				continue

			fout.write("{nn_name},{plda},{recluster},{corpus},{partition},{enhanced},{mic},{vad},{reseg},{ovl_assign},{der},{miss},{FA},{confusion}\n".format(nn_name=nn_name, plda=plda, recluster=recluster, corpus=corpus, partition=partition, enhanced=enhanced, mic=mic, vad=vad, reseg=reseg, ovl_assign=ovl_assign, der=der, miss=miss, FA=FA, confusion=confusion))


	
