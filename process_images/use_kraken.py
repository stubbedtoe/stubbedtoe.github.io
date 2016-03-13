import urllib, urllib2, json, os, requests, sys

url = 'https://api.kraken.io/v1/url'
root =  '/media/andrew/ROCKET/fullsize_images' # '/Volumes/ROCKET/fullsize_images'

params = {
	'auth': {
		'api_key' : 'c71a5fa11f4a1498f079ace0ed283c7a',
		'api_secret' : '43a2733db40757be892ac5eb584e28909e2f2e1d'
	},
	'wait' : True,
	'lossy' : True,
	'dev': False,
	's3_store':{
		'key': 'AKIAICRGAX43XMH5DZFQ',
		'secret': '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',
		'bucket': 'portfolio-ahealy',
		'region': 'eu-west-1'
	}
}





def resize(folder, userfile, medium=True, full=True, thumb=False):

	params['url'] = 'https://s3-eu-west-1.amazonaws.com/portfolio-ahealy/{}/{}'.format(
					folder, userfile)
	
	if thumb: medium, full = False, False

	to_return = {}

	if full:
		params['s3_store']['path'] = '{}/full/{}'.format(folder, userfile)
		params['resize'] = {'strategy': 'auto', 'width': 900, 'height': 900}
		data = json.dumps(params)
		request = urllib2.Request(url, data, {'Content-Type':'application/json'})
		response = urllib2.urlopen(request)
		to_return['full'] = json.loads(str(response.read()))

	if medium:
		params['s3_store']['path'] = '{}/medium/{}'.format(folder, userfile)
		params['resize'] = {'strategy': 'auto', 'width': 600, 'height': 400}
		data = json.dumps(params)
		request = urllib2.Request(url, data, {'Content-Type':'application/json'})
		response = urllib2.urlopen(request)
		to_return['medium'] = json.loads(str(response.read()))

	if thumb:
		params['s3_store']['path'] = '{}/thumb/{}'.format(folder, userfile)
		params['resize'] = {'strategy': 'auto', 'width': 225, 'height': 135, "enhance": True}
		data = json.dumps(params)
		request = urllib2.Request(url, data, {'Content-Type':'application/json'})
		response = urllib2.urlopen(request)
		to_return['thumb'] = json.loads(str(response.read()))

	return to_return




folder = sys.argv[1]

imgs =  [img for img 
			in os.listdir( os.path.join(root,folder) ) 
			if not img.startswith('thumb') and not img.startswith('.') ]
			#if img.startswith('screenshot1')]

for img in imgs:

	response_dict = resize(folder, img)
	for key, response in response_dict.iteritems():
		if (response['success']):
			print key + ' : Success. Optimized image URL: %s ' % response['kraked_url']
		else:
			print key + ' : Fail. Error message: %s ' % response['message']

#response_dict = resize(folder, 'thumb.jpg', thumb=True)
#print('THUMB: %s' % response_dict['thumb']['kraked_url'])
