#include "j2meview.h"
#include <QPainter>

J2MEView::J2MEView(QQuickItem *parent) : QQuickPaintedItem(parent)
{
    // Обязательно разрешаем отрисовку
    setFlag(ItemHasContents, true);
}

void J2MEView::setHost(RetroHost *host)
{
    if (m_host == host) return;

    if (m_host) {
        disconnect(m_host, &RetroHost::frameReady, this, &J2MEView::onFrameReady);
    }

    m_host = host;

    if (m_host) {
        connect(m_host, &RetroHost::frameReady, this, &J2MEView::onFrameReady, Qt::QueuedConnection);
    }

    emit hostChanged();
}

void J2MEView::onFrameReady(const QImage &frame)
{
    m_currentFrame = frame;
    update(); // КРИТИЧНО: Принудительно вызываем paint() на каждый новый кадр!
}

void J2MEView::paint(QPainter *painter)
{
    if (m_currentFrame.isNull()) {
        // Пока кадра нет — заливаем темным фоном
        painter->fillRect(boundingRect(), Qt::black);
        return;
    }

    // Растягиваем кадр под размеры QML элемента с сохранением пропорций
    QImage scaled = m_currentFrame.scaled(boundingRect().size().toSize(),
				      Qt::KeepAspectRatio,
				      Qt::SmoothTransformation);

    int x = (width() - scaled.width()) / 2;
    int y = (height() - scaled.height()) / 2;

    painter->drawImage(x, y, scaled);
}
