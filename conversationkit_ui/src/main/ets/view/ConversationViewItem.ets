/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 *
 */

import { ChatKitClient } from '@nimkit/chatkit';
import { AvatarColorUntil, AvatarItem, CommonAvatar } from '@nimkit/common';
import { V2NIMConversation, V2NIMMessageType } from '@nimsdk/base';
import { ConversationOperationDialog } from './ConversationOperationDialog';

@Component
export struct ConversationViewItem {
  @State conversationInfo: V2NIMConversation | null = null
  public onItemClick?: () => void
  dialogController: CustomDialogController = new CustomDialogController({
    builder: ConversationOperationDialog({
      conversationInfo: this.conversationInfo
    }),
    cornerRadius: 2,
    borderWidth: 0.5,
    width: '60%',
    borderColor: '#ffDCDFE5'
  })

  build() {
    if (this.conversationInfo !== null) {
      Row() {
        //头像
        Stack({
          alignContent: Alignment.TopEnd
        }) {
          CommonAvatar({
            item: new AvatarItem(this.conversationInfo.avatar,
              this.getAvatarShowName(this.conversationInfo.name ?? ''),
              AvatarColorUntil.getBackgroundColorById(
                ChatKitClient.nim.conversationIdUtil
                  .parseConversationTargetId(this.conversationInfo.conversationId)
              ))
          })
          if (this.conversationInfo.mute !== true && this.conversationInfo.unreadCount > 0) {
            Text(this.getUnreadCountStr(this.conversationInfo.unreadCount))
              .fontSize(12)
              .fontColor('#ffFFFFFF')
              .textAlign(TextAlign.Center)
              .backgroundColor('#ffF24957')
              .borderRadius(20)
              .height(18)
              .width(18 + (this.getUnreadCountStr(this.conversationInfo.unreadCount).length - 1) * 4)
          }

        }
        .width(42)
        .height(42)

        //名称和lastMessage
        Column() {
          Text(this.conversationInfo.name)
            .fontSize(16)
            .fontColor("#ff333333")
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .maxLines(1)
            .margin({
              bottom: 8
            })

          Text(this.getConversationContent(this.conversationInfo))
            .fontSize(13)
            .maxLines(1)
            .fontColor("#ff999999")
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width(this.conversationInfo.mute ? '80%' : '100%')
        }
        .width('60%')
        .margin({
          left: 12,
          right: 12
        }).alignItems(HorizontalAlign.Start)

        //时间戳和mute
        Column() {
          Text(this.formatTimestamp(this.conversationInfo.lastMessage?.messageRefer?.createTime ??
          this.conversationInfo.updateTime))
            .fontColor('#ffCCCCCC')
            .fontSize(12)
            .alignSelf(ItemAlign.End)
            .margin({
              bottom: 8
            })

          if (this.conversationInfo.mute) {

            Image($r('app.media.conversation_mute'))
              .width(14)
              .height(14)
          }
        }
        .width('20%')
        .margin({
          right: 12
        }).alignItems(HorizontalAlign.End)


        // //名称和lastMsg
        // Column() {
        //   Row(
        //     { space: 10 }
        //   ) {
        //
        //     Text(this.conversationInfo.name)
        //       .fontSize(16)
        //       .fontColor("#ff333333")
        //       .textOverflow({ overflow: TextOverflow.Ellipsis })
        //       .maxLines(1)
        //
        //
        //     Blank().layoutWeight(1)
        //
        //
        //     Text(this.formatTimestamp(this.conversationInfo.lastMessage?.messageRefer?.createTime ??
        //     this.conversationInfo.updateTime))
        //       .fontColor('#ffCCCCCC')
        //       .fontSize(12)
        //       .alignSelf(ItemAlign.End)
        //
        //   }
        //   .width('100%')
        //   .margin({
        //     bottom: 6
        //   })
        //   .alignItems(VerticalAlign.Center)
        //
        //
        //   Row() {
        //     Text(this.getConversationContent(this.conversationInfo))
        //       .fontSize(13)
        //       .maxLines(1)
        //       .fontColor("#ff999999")
        //       .textOverflow({ overflow: TextOverflow.Ellipsis })
        //       .width(this.conversationInfo.mute ? '80%' : '100%')
        //
        //     if (this.conversationInfo.mute) {
        //       Blank().layoutWeight(1)
        //
        //       Image($r('app.media.conversation_mute'))
        //         .width(14)
        //         .height(14)
        //     }
        //   }
        //
        // }.margin({
        //   left: 12,
        //   right: 25
        // })
        // .layoutWeight(1)
        // .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height(62)
      .onClick(() => {
        // this.goToChatPage()
        if (this.onItemClick !== undefined) {
          this.onItemClick()
        }
      })
      .backgroundColor(this.conversationInfo.stickTop ? '#ffF3F5F7' : '#ffffffff')
      .gesture(
        // 绑定可以重复触发的LongPressGesture
        LongPressGesture({ repeat: true })
          .onAction((event: GestureEvent) => {
            if (!event.repeat) {
              //show 操作弹框
              this.dialogController.open()
            }
          })
          .onActionEnd(() => {
            //do nothing
          })
      )
      .padding({
        left: 20,
        top: 10,
        bottom: 10,
        right: 20
      })
    }

  }

  /**
   * 获取未读数展示
   * @param unreadCount
   * @returns
   */
  getUnreadCountStr(unreadCount: number): string {
    if (unreadCount < 100) {
      return unreadCount + ''
    } else {
      return '99+'
    }
  }

  /**
   * 头像只显示后两位
   * @param sourceName
   * @returns
   */
  getAvatarShowName(sourceName: string): string {
    let size = sourceName.length
    if (size <= 2) {
      return sourceName
    } else {
      return sourceName.substring(size - 2)
    }
  }

  /**
   * 时间戳序列化
   * @param timestamp
   * @returns
   */
  formatTimestamp(timestamp: number): string {
    const currentDate = new Date();
    const targetDate = new Date(timestamp);
    const yearDiff = currentDate.getFullYear() - targetDate.getFullYear();
    const monthDiff = currentDate.getMonth() - targetDate.getMonth();
    const dayDiff = currentDate.getDate() - targetDate.getDate();

    if (yearDiff > 0) {
      return `${targetDate.getFullYear()}-${targetDate.getMonth() + 1}-${targetDate.getDate()}`;
    } else if (monthDiff > 0 || dayDiff > 0) {
      const hours = targetDate.getHours().toString().padStart(2, '0');
      const minutes = targetDate.getMinutes().toString().padStart(2, '0');
      return `${targetDate.getMonth() + 1}-${targetDate.getDate()} ${hours}:${minutes}`;
    } else {
      const hours = targetDate.getHours().toString().padStart(2, '0');
      const minutes = targetDate.getMinutes().toString().padStart(2, '0');
      return `${hours}:${minutes}`;
    }
  }

  /**
   * 获取会话列表展示的内容
   * @param item
   * @returns
   */
  getConversationContent(item: V2NIMConversation): string | Resource {
    switch (item.lastMessage?.messageType) {
      case V2NIMMessageType.V2NIM_MESSAGE_TYPE_TEXT:
        return item.lastMessage.text ?? ''
      case V2NIMMessageType.V2NIM_MESSAGE_TYPE_IMAGE:
        return $r('app.string.imageMessageType')
      case V2NIMMessageType.V2NIM_MESSAGE_TYPE_AUDIO:
        return $r('app.string.audioMessageType')
      case V2NIMMessageType.V2NIM_MESSAGE_TYPE_VIDEO:
        return $r('app.string.videoMessageType')
      case V2NIMMessageType.V2NIM_MESSAGE_TYPE_LOCATION:
        return $r('app.string.locationMessageType')
      case V2NIMMessageType.V2NIM_MESSAGE_TYPE_FILE:
        return $r('app.string.fileMessageType')
      case V2NIMMessageType.V2NIM_MESSAGE_TYPE_NOTIFICATION:
        return $r('app.string.notificationMessageType')
      case V2NIMMessageType.V2NIM_MESSAGE_TYPE_TIPS:
        return $r('app.string.tipMessageType')
    }
    return $r('app.string.chatMessageNonsupportType')

  }
}