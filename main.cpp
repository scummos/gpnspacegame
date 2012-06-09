#include <QtGui/QApplication>
#include <QtDeclarative/QDeclarativeView>
#include <QtDeclarative/qdeclarative.h>

int main(int argc, char** argv)
{
    QApplication app(argc, argv);
    QDeclarativeView view;
    view.setSource(QUrl::fromLocalFile("main.qml"));
    view.show();
    return app.exec();
}
