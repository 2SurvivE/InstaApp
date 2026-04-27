import hilog from '@ohos.hilog'
import process from '@ohos.process'

const DOMAIN: number = 0x0000
const DEFAULT_TAG: string = 'Unknown'
const DEFAULT_MSG: string = 'Empty msg'
const FORMAT: string = 'Thread[%{public}d] %{public}s'

export function DEBUG(tag: string = DEFAULT_TAG, msg: string = DEFAULT_MSG): void {
  hilog.debug(DOMAIN, tag, FORMAT, process.tid, msg)
}

export function INFO(tag: string = DEFAULT_TAG, msg: string = DEFAULT_MSG): void {
  hilog.info(DOMAIN, tag, FORMAT, process.tid, msg)
}

export function WARN(tag: string = DEFAULT_TAG, msg: string = DEFAULT_MSG): void {
  hilog.warn(DOMAIN, tag, FORMAT, process.tid, msg)
}

export function ERROR(tag: string = DEFAULT_TAG, msg: string = DEFAULT_MSG): void {
  hilog.error(DOMAIN, tag, FORMAT, process.tid, msg)
}

export function FATAL(tag: string = DEFAULT_TAG, msg: string = DEFAULT_MSG): void {
  hilog.fatal(DOMAIN, tag, FORMAT, process.tid, msg)
}
