import _ =  require('lodash');

interface Person{
	name: string,
	age: number
}

function component(user: Person){
	var element = document.createElement('div');
	element.innerHTML = _.join([user.name+',', 'you', 'are', user.age], ' ' );
	return element;
}

var claire = {name: 'Claire', age: 29};

document.body.appendChild(component(claire));





