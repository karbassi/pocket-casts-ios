import XCTest

@testable import PocketCastsDataModel
@testable import podcasts

class HomeGridDataHelperTests: XCTestCase {
    // Given a folder and a podcast without a folder, sort them
    // based on `sortedPodcasts` order
    func testLatestEpisodeSort() {
        let podcastInFolder = PodcastBuilder().build()
        let folder = FolderBuilder().with(podcasts: [podcastInFolder]).build()
        let podcastNotInAFolder = PodcastBuilder().build()
        let sortedPodcasts = [podcastInFolder, podcastNotInAFolder]
        var gridItems = [HomeGridItem(podcast: podcastNotInAFolder), HomeGridItem(folder: folder)]

        gridItems.sort { item1, item2 in HomeGridDataHelper.latestEpisodeSort(item1: item1, item2: item2, sortedPodcasts: sortedPodcasts) }

        XCTAssertEqual(gridItems.first?.folder, folder)
        XCTAssertEqual(gridItems[1].podcast, podcastNotInAFolder)
    }

    // Given a folder, a podcast without a folder, and an empty folder
    // sort the empty folder on the end
    func testLatestEpisodeSortWithEmptyFolders() {
        let podcastInFolder = PodcastBuilder().build()
        let folder = FolderBuilder().with(podcasts: [podcastInFolder]).build()
        let podcastNotInAFolder = PodcastBuilder().build()
        let sortedPodcasts = [podcastInFolder, podcastNotInAFolder]
        let emptyFolder = FolderBuilder().build()
        var gridItems = [
            HomeGridItem(folder: emptyFolder),
            HomeGridItem(podcast: podcastNotInAFolder),
            HomeGridItem(folder: folder)
        ]

        gridItems.sort { item1, item2 in HomeGridDataHelper.latestEpisodeSort(item1: item1, item2: item2, sortedPodcasts: sortedPodcasts) }

        XCTAssertEqual(gridItems.first?.folder, folder)
        XCTAssertEqual(gridItems[1].podcast, podcastNotInAFolder)
        XCTAssertEqual(gridItems[2].folder, emptyFolder)
    }

    // Given a folder, a podcast without a folder and multiple empty folders
    // sort the empty folders using the title
    func testMultipleEmptyFolderNames() {
        let folderNames = [
            "Olá Mundo",
            "Powerلُلُصّبُلُلصّبُررً ॣ ॣh ॣ ॣ冗",
            "˙ɐnbᴉlɐ ɐuƃɐɯ ǝɹolop ʇǝ ǝɹoqɐl ʇn ʇunpᴉpᴉɔuᴉ ɹodɯǝʇ poɯsnᴉǝ op pǝs 'ʇᴉlǝ ƃuᴉɔsᴉdᴉpɐ ɹnʇǝʇɔǝsuoɔ 'ʇǝɯɐ ʇᴉs ɹolop ɯnsdᴉ ɯǝɹo˥ 00˙Ɩ$-",
            "ДSDӺДSDӺ",
            "ਸਤਿ ਸ੍ਰੀ ਅਕਾਲ ਦੁਨਿਆ",
            "🏳0🌈️",
            "🔛🔛🔛",
            "😀"
        ]
        let podcastInFolder = PodcastBuilder().build()
        let folder = FolderBuilder().with(podcasts: [podcastInFolder]).build()
        let podcastNotInAFolder = PodcastBuilder().build()
        let sortedPodcasts = [podcastInFolder, podcastNotInAFolder]
        var gridItems = [
            HomeGridItem(podcast: podcastNotInAFolder),
            HomeGridItem(folder: folder)
        ]
        gridItems.append(contentsOf: folderNames.shuffled().map { HomeGridItem(folder: FolderBuilder().with(name: $0).build()) })

        gridItems.sort { item1, item2 in HomeGridDataHelper.latestEpisodeSort(item1: item1, item2: item2, sortedPodcasts: sortedPodcasts) }

        XCTAssertEqual(gridItems.first?.folder, folder)
        XCTAssertEqual(gridItems[1].podcast, podcastNotInAFolder)
        XCTAssertEqual(gridItems[2].folder?.name, folderNames.first)
        XCTAssertEqual(gridItems[3].folder?.name, folderNames[1])
        XCTAssertEqual(gridItems[4].folder?.name, folderNames[2])
        XCTAssertEqual(gridItems[5].folder?.name, folderNames[3])
        XCTAssertEqual(gridItems[6].folder?.name, folderNames[4])
        XCTAssertEqual(gridItems[7].folder?.name, folderNames[5])
        XCTAssertEqual(gridItems[8].folder?.name, folderNames[6])
        XCTAssertEqual(gridItems[9].folder?.name, folderNames[7])
    }

    // Given a podcast with unfinished episodes and one without
    // only keep the one with unfinished episodes
    func testItemsWithUnfinishedEpisodesRemovesFullyPlayedPodcasts() {
        let unfinishedPodcast = PodcastBuilder().build()
        let fullyPlayedPodcast = PodcastBuilder().build()
        let allPodcasts = [unfinishedPodcast, fullyPlayedPodcast]
        let gridItems = [HomeGridItem(podcast: fullyPlayedPodcast), HomeGridItem(podcast: unfinishedPodcast)]
        let unfinishedCounts: [String: Int32] = [unfinishedPodcast.uuid: 3]

        let filteredItems = HomeGridDataHelper.itemsWithUnfinishedEpisodes(gridItems, allPodcasts: allPodcasts, unfinishedCounts: unfinishedCounts)

        XCTAssertEqual(filteredItems.count, 1)
        XCTAssertEqual(filteredItems.first?.podcast, unfinishedPodcast)
    }

    // Given a folder where every podcast is fully played
    // remove the folder
    func testItemsWithUnfinishedEpisodesRemovesFullyPlayedFolders() {
        let fullyPlayedPodcast = PodcastBuilder().build()
        let otherFullyPlayedPodcast = PodcastBuilder().build()
        let folder = FolderBuilder().with(podcasts: [fullyPlayedPodcast, otherFullyPlayedPodcast]).build()
        let allPodcasts = [fullyPlayedPodcast, otherFullyPlayedPodcast]
        let gridItems = [HomeGridItem(folder: folder)]

        let filteredItems = HomeGridDataHelper.itemsWithUnfinishedEpisodes(gridItems, allPodcasts: allPodcasts, unfinishedCounts: [:])

        XCTAssertTrue(filteredItems.isEmpty)
    }

    // Given a folder with one fully played podcast and one with unfinished episodes
    // keep the folder
    func testItemsWithUnfinishedEpisodesKeepsFoldersWithUnfinishedPodcasts() {
        let fullyPlayedPodcast = PodcastBuilder().build()
        let unfinishedPodcast = PodcastBuilder().build()
        let folder = FolderBuilder().with(podcasts: [fullyPlayedPodcast, unfinishedPodcast]).build()
        let allPodcasts = [fullyPlayedPodcast, unfinishedPodcast]
        let gridItems = [HomeGridItem(folder: folder)]
        let unfinishedCounts: [String: Int32] = [unfinishedPodcast.uuid: 1, fullyPlayedPodcast.uuid: 0]

        let filteredItems = HomeGridDataHelper.itemsWithUnfinishedEpisodes(gridItems, allPodcasts: allPodcasts, unfinishedCounts: unfinishedCounts)

        XCTAssertEqual(filteredItems.first?.folder, folder)
    }

    // Given an empty folder
    // remove it, since there's nothing left to listen to
    func testItemsWithUnfinishedEpisodesRemovesEmptyFolders() {
        let emptyFolder = FolderBuilder().build()
        let gridItems = [HomeGridItem(folder: emptyFolder)]

        let filteredItems = HomeGridDataHelper.itemsWithUnfinishedEpisodes(gridItems, allPodcasts: [], unfinishedCounts: [:])

        XCTAssertTrue(filteredItems.isEmpty)
    }
}
