export interface HotSearchDetailResponse {
  code: number
  data: SearchDetail[]
  message: string
}

export interface SearchDetail {
  searchWord: string
  score: number
  content: string
  source: number
  iconType: number
  iconUrl?: string
  url: string
  alg: string
}