class Song {
    constructor(name, path, segment) {
        this.name = name;
        this.path = path;
        this.segment = segment;
    }

    segmentListener = (audioCtrl) => {
        if (this.segment.end && audioCtrl.currentTime >= this.segment.end) {
            console.log(`Audio time ${audioCtrl.currentTime} is past segment end ${this.segment.end} for song ${this.name}`);
            audioCtrl.pause();
            this.reset(audioCtrl);
        }
    };

    playSegment(audioCtrl) {
        console.log(`Playing segment from ${this.segment.start} to ${this.segment.end}`);
        audioCtrl.pause();
        audioCtrl.currentTime = this.segment.start;

        // replace the oncanplaythrough listener by assigning it - using addEventListener causes a lot of problems
        // since corresponding removeEventListener doesn't always appear to remove it
        audioCtrl.oncanplaythrough = () => {
            console.log(`audio current time = ${audioCtrl.currentTime}`);
            audioCtrl.ontimeupdate = () => this.segmentListener(audioCtrl);
            audioCtrl.play();
        };
    }

    reset(audioCtrl) {
        console.log(`Removing event listener for song ${this.name}`);
        audioCtrl.ontimeupdate = null;
        audioCtrl.oncanplaythrough = null;
    }
}

class Segment {
    constructor(start, end) {
        this.start = start;
        this.end = end;
    }
}

class Songs {
    constructor(songsAsJson, audioCtrl) {
        this.songs = [];
        this.recentSongIndices = [];
        this.curSong = null;
        this.audioCtrl = audioCtrl;
        songsAsJson.forEach((songJson => this.songs.push(new Song(songJson.name, songJson.path,
            new Segment(songJson.segment.start, songJson.segment.end)))));
    }

    getRandomSong() {
        const numSongs = this.songs.length;
        if (this.recentSongIndices.length > 10) {
            this.recentSongIndices.shift(); // remove the oldest i.e. zeroth element - same as splice(0, 1)
        }
        let nextSongIdx;
        do {
            nextSongIdx = Math.floor(Math.random() * numSongs);
        } while (this.recentSongIndices.includes(nextSongIdx));
        this.recentSongIndices.push(nextSongIdx);
        return this.songs[nextSongIdx];
    }

    changeSong() {
        this.audioCtrl.pause();
        this.curSong && this.curSong.reset(this.audioCtrl);
        this.curSong = this.getRandomSong();
        console.log(`Selected song ${this.curSong.path}, url encoded to ${encodeURI(this.curSong.path)}`);
        this.audioCtrl.src = encodeURI(this.curSong.path);
        this.audioCtrl.load();
    }

    getCurSong() {
        return this.curSong;
    }

    playCurSong() {
        this.curSong && this.curSong.playSegment(this.audioCtrl);
    }
}