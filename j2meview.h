#pragma once

#include <QQuickPaintedItem>
#include <QImage>
#include "retrohost.h"

class J2MEView : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(RetroHost* host READ host WRITE setHost NOTIFY hostChanged)

public:
    explicit J2MEView(QQuickItem *parent = nullptr);

    RetroHost* host() const { return m_host; }
    void setHost(RetroHost *host);

    void paint(QPainter *painter) override;

signals:
    void hostChanged();

private slots:
    void onFrameReady(const QImage &frame);

private:
    RetroHost *m_host = nullptr;
    QImage m_currentFrame;
};
