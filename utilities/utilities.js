const fs = require('fs');
const zlib = require('zlib');

exports.stringToBytes = (str) => {
	return ethers.utils.hexlify(ethers.utils.toUtf8Bytes(str));
}

exports.bytesToString = (str) => {
	return ethers.utils.toUtf8String(str)
}

exports.emptyBytes = () => {
	return ethers.utils.hexlify(ethers.utils.toUtf8Bytes(""));
}

exports.readFile = (path) => {
	return fs.readFileSync(path, { encoding: 'utf8' });
}

exports.writeFile = (path, data) => {
	fs.writeFileSync(path, data);
}

exports.emptyAddress = "0x0000000000000000000000000000000000000000"

exports.parseBase64DataURI = (uri) => {
	const data = uri.split("base64,")[1]
	const buff = Buffer.from(data, 'base64');
	return buff.toString('ascii');
}

exports.parseEscapedDataURI = (uri) => {
	const data = uri.split("data:")[1].split(",")[1]
	return decodeURIComponent(data)
}

exports.chunkSubstr = (str, size) => {
	return str.split(new RegExp("(.{"+size.toString()+"})")).filter(O=>O);
}

exports.toBase64String = (data) => {
	return Buffer.from(data).toString('base64')
}

exports.toGZIPBase64String = (data) => {
	return zlib.deflateSync(data).toString('base64');
}

exports.toURLSafe = (data) => {
	return encodeURIComponent(data)
}

exports.toURLSafeDouble = (data) => {
	return encodeURIComponent(encodeURIComponent(data))
}

exports.parseDoubleURLEncodedDataURI = (uri) => {
	let firstDecode = decodeURIComponent(uri)
	const data = firstDecode.split("data:")[1].split(",")[1]
	return decodeURIComponent(data)
}
