// 给Kotlin代码调用用的导出类

import { IServiceProvider } from '../interface/IServiceProvider'
import {DEBUG, ERROR, FATAL, WARN, INFO} from './Logger'

export class LogServiceProvider implements IServiceProvider{
  debug(tag: string, msg: string): void {
    DEBUG(tag, msg)
  }

  info(tag: string, msg: string): void {
    INFO(tag, msg)
  }

  warn(tag: string, msg: string): void {
    WARN(tag, msg)
  }

  error(tag: string, msg: string): void {
    ERROR(tag, msg)
  }

  fatal(tag: string, msg: string): void {
    FATAL(tag, msg)
  }
}