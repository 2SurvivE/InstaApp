import { rcp } from '@kit.RemoteCommunicationKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { FEED_URL } from '../common/constants/ApiConstants'
import { FeedResponse } from './dto/FeedResponse'
import { VideoFeedItem } from '../model/VideoFeedItem'
import { DEBUG, ERROR, INFO, FATAL, WARN } from "../common/utils/logutils/index";

const tag = 'requestFeedList'

export async function requestFeedList(): Promise<VideoFeedItem[]> {
  let session: rcp.Session|undefined = undefined;

  try{
    session = rcp.createSession()
    if(session === undefined){
      ERROR(tag,`Can't create rcpSession`)
      return [];
    }

    const response: rcp.Response = await session.get(FEED_URL)

    if (response.statusCode !== 200) {
      throw new Error(`HTTP error: ${response.statusCode}`)
    }

    const body: string | null = response.toString()
    const feedResponse: FeedResponse = JSON.parse(body!) as FeedResponse
    if (feedResponse.code !== 0) {
      ERROR(tag,`Response code is ${feedResponse.code}, plz check`)
      return []
    }
    return feedResponse.data
  } catch (err) {
    ERROR(tag,`Error for ${JSON.stringify(err)}`)
    return []
  } finally {
    if(session !== undefined)
      session.close()
  }
}