export enum AppInitStatus {
  INITTING = 0,
  SUCCESS = 1,
  FAILED = 2
}

export class AppInitState {
  static status: AppInitStatus = AppInitStatus.INITTING
  static errorMessage: string = ''

  static reset(): void {
    AppInitState.status = AppInitStatus.INITTING
    AppInitState.errorMessage = ''
  }

  static success(): void {
    AppInitState.status = AppInitStatus.SUCCESS
    AppInitState.errorMessage = ''
  }

  static failed(message: string): void {
    AppInitState.status = AppInitStatus.FAILED
    AppInitState.errorMessage = message
  }
}