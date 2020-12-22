#!/usr/bin/env node

// Use:
//     ./main.js

// @ts-check

/** @typedef {Tile[][]} TileMap */

const input = require("fs").readFileSync("input.txt", { encoding: "utf-8" });

const tilesStr = input.split("\n\n");

class Tile {
	/**
	 * @param {number} id
	 * @param {string[]} content
	 */
	constructor(id, content) {
		this.id = id;
		this.content = content;
	}

	get width() { return this.content[0].length; }
	get height() { return this.content.length; }

	get top() { return this.content[0]; }
	get bottom() { return this.content[this.content.length - 1]; }
	get left() { return this._left ?? (this._left = this.content.map(l => l[0]).join("")); }
	get right() { return this._right ?? (this._right = this.content.map(l => l[l.length - 1]).join("")); }

	get rotated() {
		const h = this.height;
		const w = this.width;

		const contents = new Array(h);
		for (let y = 0; y < h; ++y)
			contents[y] = new Array(w);

		for (let y = 0; y < h; ++y) {
			for (let x = 0; x < w; ++x)
				contents[y][x] = this.content[h - x - 1][y];
		}

		return new Tile(this.id, contents.map(row => row.join("")));
	}

	get verticalFlipped() { return new Tile(this.id, [...this.content].reverse()); }
	get horizontalFlipped() { return this.verticalFlipped.rotated.rotated; }

	getVariations() {
		const rotated = [
			this,
			this.rotated,
			this.rotated.rotated,
			this.rotated.rotated.rotated,
		];

		const res = [];
		for (const t of rotated) {
			res.push(t);
			res.push(t.verticalFlipped);
			res.push(t.horizontalFlipped)
			res.push(t.horizontalFlipped.verticalFlipped);
		}
		return removeDuplicates(res);
	}

	/**
	 * @param {string} entry
	 * @return {Tile}
	*/
	static parse(entry) {
		const [idLine, ...content] = entry.trim().split("\n");
		const id = Number(idLine.split(" ")[1].slice(0, -1));
		return new Tile(id, content);
	}

	/**
	 * @param {Tile} a
	 * @param {Tile} b
	 */
	static sameId(a, b) {
		return a.id == b.id;
	}

	/**
	 * @param {Tile} a
	 * @param {Tile} b
	 */
	static areEqual(a, b) {
		return Tile.sameId(a, b)
			&& a.content.length === b.content.length
			&& a.content.every((line, index) => line === b.content[index]);
	}

	print() {
		console.log(`Tile ${this.id}:`);
		this.content.forEach(c => console.log(c));
	}
}

const tiles = tilesStr.map(Tile.parse);

/** @param {Tile[]} tiles */
function removeDuplicates(tiles) {
	return tiles.filter((t, index) => !tiles.some((c, cIndex) => index < cIndex && Tile.areEqual(t, c)));
}

/** @param {Tile[]} tiles */
function alignTiles(tiles) {
	const size = Number(Math.sqrt(tiles.length));

	const tileMap = new Array(size);
	for (let i = 0; i < size; ++i)
		tileMap[i] = new Array(size);

	const variations = tiles.map(e => e.getVariations()).flat();
	return findNextMatchingTile(variations, size, 0, 0, tileMap);
}


/**
 * @param {Tile[]} tileVariations
 * @param {number} size
 * @param {number} x
 * @param {number} y
 * @param {TileMap} tileMap
 * @return {TileMap | undefined}
 */
function findNextMatchingTile(tileVariations, size, x, y, tileMap) {
	const topTileToMatch = tileMap[y - 1]?.[x] ?? undefined;
	const leftTileToMatch = tileMap[y]?.[x - 1] ?? undefined;

	let candidates = [];
	for (const variation of tileVariations) {
		const fitsLeft = leftTileToMatch ? (variation.left === leftTileToMatch.right) : true;
		const fitsTop = topTileToMatch ? (variation.top === topTileToMatch.bottom) : true;
		if (fitsLeft && fitsTop) {
			candidates.push(variation);
		}
	}

	const offset = x + y * size;
	const nextOffset = offset + 1;

	if (nextOffset < (size * size)) {
		const nextX = nextOffset % size;
		const nextY = (nextOffset / size) | 0;

		for (const candidate of candidates) {
			//const tileMapCandidate = deepCopyTileMap(tileMap);
			// tileMapCandidate[y][x] = candidate;
			tileMap[y][x] = candidate;
			const remainingTiles = tileVariations.filter(t => t.id !== candidate.id);

			// console.log(`Next: ${nextX}, ${nextY}`);

			const fileTileMap = findNextMatchingTile(remainingTiles, size, nextX, nextY, tileMap);
			if (fileTileMap)
				return fileTileMap;

			tileMap[y][x] = undefined;
		}

		return undefined;
	}

	tileMap[y][x] = candidates[0];
	return tileMap;
}

const alignedTiles = alignTiles(tiles);
const size = alignedTiles.length;
const corners = [
	alignedTiles[0][0],
	alignedTiles[size - 1][0],
	alignedTiles[0][size - 1],
	alignedTiles[size - 1][size - 1],
];
const part1 = corners.map(c => c.id).reduce((a,b) => a * b);

console.log(`IDs of tiles in corners; Part 1: ${part1} (${corners[0].id} * ${corners[1].id} * ${corners[2].id} * ${corners[3].id})`)
