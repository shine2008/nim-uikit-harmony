/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 *
 */

import { StorageRepo, TeamRepo } from '@nimkit/chatkit';
import { ChooseAvatarDialog, NavigationBackBuilder } from '@nimkit/common';
import fs from '@ohos.file.fs';

export interface AvatarEditParams {
  avatar: string,
  showSave?: boolean
}


@Component
struct TeamAvatarPage {
  pathStack: NavPathStack = new NavPathStack()
  @State avatar?: string | null = null
  //显示保存按钮
  @State showSave: boolean = true

  //图片选择结果处理
  onImageChosen = async (filePath: string) => {

    try {
      const cacheDir = getContext(this).getApplicationContext().cacheDir
      const filePathSplit = filePath.split('/')
      const dir = cacheDir + '/' + filePathSplit[filePathSplit.length - 1]
      // 将文件 拷贝到 临时目录
      const file = fs.openSync(filePath, fs.OpenMode.READ_ONLY)
      fs.copyFileSync(file.fd, dir)

      const task = StorageRepo.createUploadFileTask({
        filePath: dir,
        sceneName: 'nim_default_profile_icon'
      })
      if (task) {
        const url = await StorageRepo.uploadFile(task, (progress: number) => {
          // NECommonUtils.showToast($r('app.string.avatar_uploading', progress * 100))
        })
        this.avatar = url
      }
    } catch (err) {
      console.log(err)
    }
  }

  //头像选择弹框
  chooseDialogController: CustomDialogController = new CustomDialogController({
    builder: ChooseAvatarDialog({ onImageChosen: this.onImageChosen }),
    cornerRadius: 0,
    alignment: DialogAlignment.Bottom,
    backgroundColor: Color.Transparent,
    backgroundBlurStyle: BlurStyle.NONE,
    height: 140,
  })

  build() {
    NavDestination() {
      NavigationBackBuilder({
        title: $r('app.string.team_edit_avatar'),
        backgroundColor: '#ffEFF1F4',
        leftButtonTitle: $r('app.string.cancel'),
        leftButtonAction: () => {
          this.pathStack.pop()
        },
        rightButtonTitle: this.showSave ? $r('app.string.save') : undefined,
        rightButtonAction: this.showSave ? () => {
          this.pathStack.pop(this.avatar)
        } : undefined
      })

      Column() {
        Stack({ alignContent: Alignment.Center }) {
          Stack({ alignContent: Alignment.BottomEnd }) {
            if (this.avatar) {
              Image(this.avatar)
                .height(80)
                .width(80)
                .borderRadius(40)
            }
            Image($r('app.media.camera'))
              .width(24)
              .height(24)
              .borderRadius(12)

          }
          .height(80)
          .width(80)
          .borderRadius(40)
          .onClick(() => {
            this.chooseDialogController.open()
          })
        }
        .backgroundColor(Color.White)
        .padding({
          top: 20,
          bottom: 20
        })
        .width('90%')
        .margin({
          top: 12,
          bottom: 12,
        })
        .borderRadius(8)

        Column() {
          Text($r('app.string.team_default_avatar_selector'))
            .fontSize(16)
            .fontColor('#333333')
            .margin({
              bottom: 16
            })

          Row() {
            ForEach(TeamRepo.teamDefaultIcons, (avatar: string) => {

              Stack({ alignContent: Alignment.Center }) {
                Image(avatar)
                  .height(32)
                  .width(32)
              }
              .width(48)
              .height(48)
              .backgroundColor(
                avatar === this.avatar ? '#ffF4F4F4' : '#ffffffff'
              )
              .borderRadius(8)
              .onClick(() => {
                this.avatar = avatar
              })

            })
          }.width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

        }
        .alignItems(HorizontalAlign.Start)
        .backgroundColor(Color.White)
        .padding({
          top: 16,
          bottom: 16,
          left: 16,
          right: 16
        })
        .borderRadius(8)
        .width('90%')
        .margin({
          bottom: 12,
        })
      }

    }
    .hideTitleBar(true)
    .backgroundColor('#ffEFF1F4')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
      let params = context.pathStack.getParamByName('TeamAvatarPage')[0] as AvatarEditParams
      this.avatar = params.avatar
      this.showSave = params.showSave ?? true
    })
  }
}

@Builder
export function TeamAvatarPageBuilder() {
  TeamAvatarPage()
}