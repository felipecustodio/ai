// map
var mapimg;
var clat = 0;
var clon = 0;
var ww = 1280;
var hh = 720;
var zoom = 1.4;

// dataset
var countries;

// colors
// #F1D18A
// #D45D79
// #FBF0F0


// trail
var i = 1;
var points = [];
var connections = [];

var stop;
var runs = 0;

// font
var font;

// web mercator
function mercX(lon) {
  lon = radians(lon);
  var a = (256 / PI) * pow(2, zoom);
  var b = lon + PI;
  return a * b;
}

function mercY(lat) {
  lat = radians(lat);
  var a = (256 / PI) * pow(2, zoom);
  var b = tan(PI / 4 + lat / 2);
  var c = PI - log(b);
  return a * c;
}

function colorAlpha(aColor, alpha) {
  var c = color(aColor);
  if (alpha <= 0.05) {
      alpha = 0.05;
  }
  return color('rgba(' +  [red(c), green(c), blue(c), alpha].join(',') + ')');
}

function preload() {
    mapimg = loadImage('https://api.mapbox.com/styles/v1/crochi/cjg9xowdu004i2rpgwfv7en0j/static/' +
    clon + ',' + clat + ',' + zoom + '/' +
    ww + 'x' + hh + '@2x' +
    '?access_token=pk.eyJ1IjoiY3JvY2hpIiwiYSI6ImNqZzh5dDN3cThzaWMyd21kbzh0cWxvZGgifQ.WGF1BgdeYFXPIC8TStBCxA');
    countries = loadStrings('data/countries.csv');
    font = loadFont('assets/CPMono_Bold.otf');
}

function setup() {
	createCanvas(ww, hh);

    smooth();
	frameRate(20);

	translate(width/2, height/2);

	imageMode(CENTER);
	image(mapimg, 0, 0, 1280, 720);

	var cx = mercX(clon);
  	var cy = mercY(clat);

	// parse countries with latitude, longitude
	for (var i = 1; i < countries.length; i++) {
		var data = countries[i].split(/,/);

		var lat = data[1];
    	var lon = data[2];

		var x = mercX(lon) - cx;
	    var y = mercY(lat) - cy;

		if (x < - width/2) {
	    	x += width;
	    } else if (x > width / 2) {
	    	x -= width;
	    }

		var pos = createVector(x,y);
		append(points,pos);
	}

    stop = int(random(0,points.length - 1));
}

function draw() {
	translate(width / 2, height / 2);

    imageMode(CENTER);
    image(mapimg, 0, 0, 1280, 720);

    // draw all countries points
    for (var j = 0; j < points.length; j++) {
        strokeWeight(1);
        stroke("#FBF0F0");
        fill("#FBF0F0");
		ellipse(points[j].x, points[j].y, 4, 4);
	}

    // create connection
    country1 = countries[i].split(/,/);
    country2 = countries[i+1].split(/,/);
    console.log(country1[3] + " -> " + country2[3]);

    // start/end points
    strokeWeight(1);
    stroke("#F1D18A");
    fill("#F1D18A");
    ellipse(points[i-1].x, points[i-1].y, 4);
    ellipse(points[i].x, points[i].y, 4);

    var connection = createVector(i-1,i,1);
    append(connections, connection);

    // draw all connections
    for (var j = 0; j < connections.length; j++) {
        connection = connections[j];
        // strokeWeight(connection.z + 1);
        strokeWeight(2);
        stroke(colorAlpha('#F1D18A', connection.z));
        fill(colorAlpha('#F1D18A', connection.z - 0.05));
        connections[j].z -= 0.15;
        line(points[connection.x].x,points[connection.x].y,points[connection.y].x,points[connection.y].y);
        ellipse(points[connection.x].x,points[connection.x].y, 4);
    }

    // test 'cycle'
    if (i >= stop + 5) {
        i = stop;
        runs += 1;
        if (runs > 50) {
            noLoop();
        }
    }
    i++;

    // GUI
    textFont(font);
    textSize(36);
    text("R$" + float(i), -450, 200);
}
