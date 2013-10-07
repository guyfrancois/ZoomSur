﻿/**
 * 
 */
class swhx.Deserializer {

	var buf : String;
	var pos : Number;
	var length : Number;
	var cache : Array;
	var scache : Array;

	public function Deserializer(buf: String) {
		this.buf = buf;
		length = buf.length;
		pos = 0;
		scache = new Array();
		cache = new Array();
	}

	private function readDigits(): Number {
 		var k = 0;
 		var s = false;
 		var fpos = pos;
 		while( true ) {
 			var c = buf.charCodeAt(pos);
 			if( c == null || isNaN(c) )
 				break;
 			if( c == 45 ) { // negative sign
 				if( pos != fpos )
 					break;
 				s = true;
 				pos++;
 				continue;
 			}
			c -= 48;
 			if( c < 0 || c > 9 )
 				break;
 			k = k * 10 + c;
 			pos++;
 		}
 		if( s )
 			k *= -1;
 		return k;
 	}

	public function deserializeObject(o,isHash) {
		var e = isHash?104:103; /* h or g */
 		while( true ) {
 			if( pos >= length )
 				throw "Invalid object";
 			if( buf.charCodeAt(pos) == e )
 				break;
 			var k = deserialize();
 			if( (typeof k) != "string" )
 				throw "Invalid object key";
 			var v = deserialize();
			o[k] = v;
 		}
 		pos++;
	}

 	public function deserialize() : Object {
		switch( buf.charCodeAt(pos++) ) {
 		case 110: // n
 			return null;
 		case 116: // t
 			return true;
 		case 102: // f
 			return false;
 		case 122: // z
 			return 0;
 		case 105: // i
 			return readDigits();
 		case 100: // d
 			var p1 = pos;
 			while( true ) {
 				var c = buf.charCodeAt(pos);
 				// + - . , 0-9
 				if( (c >= 43 && c < 58) || c == 101 /*e*/ || c == 69 /*E*/ )
 					pos++;
 				else
 					break;
 			}
 			var s = buf.substr(p1,pos-p1);
 			var f = parseFloat(s);
 			if( f == null )
 				throw ("Invalid float "+s);
 			return f;
 		case 121: // y
 			var len = readDigits();
 			if( buf.charAt(pos++) != ":" || length - pos < len )
 				throw "Invalid string length";
			var s = buf.substr(pos,len);
			pos += len;
			s = unescape(s);
			scache.push(s);
			return s;
 		case 107: // k
 			return Number.NaN;
 		case 109: // m
 			return Number.NEGATIVE_INFINITY;
 		case 112: // p
 			return Number.POSITIVE_INFINITY;
 		case 97: // a
 			var a = new Array();
 			cache.push(a);
 			while( true ) {
 				if( pos >= length )
 					throw "Invalid array";
 				var c = buf.charCodeAt(pos);
 				if( c == 104 ) { /*h*/
					pos++;
 					break;
				}
 				if( c == 117 ) { /*u*/
					pos++;
 					var n = readDigits();
 					if( n <= 0 )
 						throw "Invalid array null counter";
 					a[a.length+n-1] = null;
 				} else
 					a.push(deserialize());
 			}
 			return a;
 		case 111: // o
	 		var o = new Object;
	 		cache.push(o);
			deserializeObject(o,false);
			return o;
 		case 114: // r
 			var n = readDigits();
 			if( n < 0 || n >= cache.length )
 				throw "Invalid reference";
 			return cache[n];
 		case 82: // R
			var n = readDigits();
			if( n < 0 || n >= scache.length )
				throw "Invalid string reference";
			return scache[n];
 		case 120: // x
			throw deserialize();
		case 99: // c
	 		throw "Flash deserializer cannot handle classes";
		case 119: // w
			throw "Flash deserializer cannot handle enumerations";
        case 98: // b --- Hashes are handled like objects
	 		var o = new Object;
	 		cache.push(o);
			deserializeObject(o,true);
			return o;
		// deprecated
 		case 115: // s
 			var len = readDigits();
 			if( buf.charAt(pos++) != ":" || length - pos < len )
				throw "Invalid string length";
			var s = buf.substr(pos,len);
 			pos += len;
			scache.push(s);
			return s;
 		case 106: // j
 			var len = readDigits();
 			if( buf.charAt(pos++) != ":" )
 				throw "Invalid string length";
 			var s = buf.substr(pos,len);
 			pos += len;
 			s = s.split("\\r").join("\r").split("\\n").join("\n").split("\\\\").join("\\");
 			scache.push(s);
 			return s;

 		default:
 		}
 		pos--;
 		throw("Invalid char "+buf.charAt(pos)+" at position "+pos);
 	}

	public static function run( v : String ) : Object {
		return (new Deserializer(v)).deserialize();
	}
}