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

        // replace the oncanplaythrough listener by assigning it - using addEventListener causes a lot of problems
        // since corresponding removeEventListener doesn't always appear to remove it
        audioCtrl.oncanplaythrough = () => {
            console.log(`audio current time = ${audioCtrl.currentTime}`);
            audioCtrl.ontimeupdate = () => this.segmentListener(audioCtrl);
            audioCtrl.play();
        };

        audioCtrl.currentTime = this.segment.start;
    }

    reset(audioCtrl) {
        console.log(`Removing event listener for song ${this.name}`);
        audioCtrl.ontimeupdate = null;
        audioCtrl.oncanplaythrough = null;
    }

    updateSegmentTimes(start, end) {
        this.segment.start = start;
        this.segment.end = end;
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
        this.curSongIdx = -1;
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

        return nextSongIdx;
    }

    changeSong() {
        this.audioCtrl.pause();
        this.curSong && this.curSong.reset(this.audioCtrl);
        const nextSongIdx = this.getRandomSong();
        this.curSongIdx = nextSongIdx;
        this.loadSongFromCurIdx();
    }

    nextSong() {
        this.audioCtrl.pause();
        this.curSong && this.curSong.reset(this.audioCtrl);
        if (this.curSongIdx === this.songs.length - 1) {
            console.log("Reached last song");
            return;
        }
        this.curSongIdx++;
        this.loadSongFromCurIdx();
    }

    prevSong() {
        this.audioCtrl.pause();
        this.curSong && this.curSong.reset(this.audioCtrl);
        if (this.curSongIdx === 0) {
            console.log("Reached first song");
            return;
        }
        this.curSongIdx--;
        this.loadSongFromCurIdx();
    }

    loadSongFromCurIdx() {
        this.curSong = this.songs[this.curSongIdx];
        console.log(`Selected song ${this.curSong.path}, url encoded to ${encodeURI(this.curSong.path)}`);
        this.audioCtrl.src = encodeURI(this.curSong.path);
        this.audioCtrl.load();
    }

    deleteCurSong() {
        this.audioCtrl.pause();
        if (!this.curSong) {
            return;
        }
        this.curSong.reset(this.audioCtrl);
        this.songs.splice(this.curSongIdx, 1);

        // if we deleted the last song, adjust curSongIdx, otherwise curSongIdx will be
        // automatically at next song
        if (this.curSongIdx >= this.songs.length) {
            this.curSongIdx = this.songs.length - 1;
        }
        this.loadSongFromCurIdx();
    }
    getCurSong() {
        return this.curSong;
    }

    playCurSong() {
        this.curSong && this.curSong.playSegment(this.audioCtrl);
    }
    toJSON() {
        return JSON.stringify(this.songs);
    }
}