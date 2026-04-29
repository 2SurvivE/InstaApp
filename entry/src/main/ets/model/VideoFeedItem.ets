export interface VideoFeedItem {
  id: string
  coverUrl: string
  videoUrl: string
  authorAvatarUrl: string
  authorNickname: string
  coverWidth: number
  coverHeight: number
  likeCount?: number
  title?: string
}