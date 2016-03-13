import sys, os, json
#from subprocess import call, check_output
import paramiko
paramiko.util.log_to_file('/tmp/paramiko.log')


def upload_file(sftp, local_dir, remote_dir, filename):

	os.chmod(os.path.join(local_dir, filename), 0664)

	try:
		sftp.put(os.path.join(local_dir, filename), os.path.join(remote_dir, filename))
		print('uploading {} to {}'.format(filename, remote_dir))
	except:
		print('error uploading {} in {}'.format(filename, local_dir))
		sftp.close()
		transport.close()
		exit(1)

def upload_folder(sftp, local_dir, remotepath, to_upload):


	if to_upload not in sftp.listdir():
		sftp.mkdir(to_upload)

	for foldername, subfolders, filenames in os.walk(to_upload):

		print('in '+foldername)

		remote_temp = os.path.join(remotepath, target, foldername[len(to_upload):])

		try:
			sftp.chdir(remote_temp)
		except:
			print('error changing to {}'.format(remote_temp))

		folders = [f for f in subfolders if f not in sftp.listdir()]

		for f in folders:
			try:
				sftp.mkdir(f)
				print('made '+f+' subfolder')
			except:
				print('error making {} in {}'.format(f, foldername))
				sftp.close()
				transport.close()
				exit(1)
		
		for f in filenames:
			upload_file(sftp, foldername, remote_temp, f)



with open("configuration.json") as f:
    config = json.load(f)


# Open a transport

if len(sys.argv) < 2:
	print('usage: path_to_upload <path_to_remote>')
	exit(1)

host = config['host']
port = config['port']
transport = paramiko.Transport((host, port))

# Auth

username = config['username']
password = config['password']
transport.connect(username = username, password = password)

# Go!

sftp = paramiko.SFTPClient.from_transport(transport)

to_upload = sys.argv[1]
remote_dir = config['remote_dir']
remote_subdir = '' if len(sys.argv) < 3 else sys.argv[2] 
remotepath = os.path.join(remote_dir, remote_subdir)
sftp.chdir(remotepath)

if not os.path.isdir(os.path.join(os.getcwd(), to_upload)):
	#its a single file so just upload it
	upload_file(sftp, os.getcwd(), remotepath, to_upload)

else:

	upload_folder(sftp, os.getcwd(), remotepath, to_upload)

sftp.close()
transport.close()






